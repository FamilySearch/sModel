import Foundation
import FMDB

public typealias ResultDictionary = Dictionary<String, Any>


public enum ColumnType {
  case text, real, int, bool, date, array, dictionary
}

public struct ColumnConstraint: OptionSet {
  public let rawValue: Int
  
  public init(rawValue: Int) {
    self.rawValue = rawValue
  }
  
  public static let primary = ColumnConstraint(rawValue: 1)
  public static let unique = ColumnConstraint(rawValue: 2)
  public static let none = ColumnConstraint(rawValue: 4)
}

public struct ColumnMeta {
  let name: String
  let type: ColumnType
  let constraint: ColumnConstraint
  
  public init(name: String, type: ColumnType, constraint: ColumnConstraint = .none) {
    self.name = name
    self.type = type
    self.constraint = constraint
  }
}

public struct KeyData {
  let whereClause: String
  let values: Array<Any>
  let columns: Array<ColumnMeta>
}


open class BaseModel: NSObject {
  public var isDeleted = false
  public var existsInDatabase = false

  required override public init() {
    super.init()
  }

  public class func generateUUID() -> String {
    return UUID().uuidString
  }

  open func didDelete() { } //No op by default
}


public protocol ModelDef: class {
  var isDeleted: Bool { get set }
  var existsInDatabase: Bool { get set }
  static var sqlTableName: String { get }
  static var columns: Array<ColumnMeta> { get }

  associatedtype ModelType: BaseModel

  func value(forKey name: String) -> Any?
}


extension ModelDef {

  //MARK: Convenience methods for getting data out of db
  public static func firstInstanceWhere(_ whereClause: String, params: Any...) -> ModelType? {
    let query = "SELECT * FROM \(sqlTableName) WHERE \(whereClause) LIMIT 1"
    let instances = fetchInstances(query: query, paramArray: params)
    return instances.first
  }

  public static func instances(_ query: String, params: Any...) -> Array<ModelType> {
    return fetchInstances(query: query, paramArray: params)
  }

  public static func instancesWhere(_ whereClause: String, params: Any...) -> Array<ModelType> {
    let query = "SELECT * FROM \(sqlTableName) WHERE \(whereClause)"
    return fetchInstances(query: query, paramArray: params)
  }

  public static func instancesOrderedBy(_ orderByClause: String) -> Array<ModelType> {
    let query = "SELECT * FROM \(sqlTableName) ORDER BY \(orderByClause)"
    return fetchInstances(query: query, paramArray: [])
  }

  public static func allInstances() -> Array<ModelType> {
    let query = "SELECT * FROM \(sqlTableName)"
    return fetchInstances(query: query, paramArray: [])
  }

  private static func fetchInstances(query: String, paramArray: Array<Any>) -> Array<ModelType> {
    var instances = [ModelType]()
    //Checking for an array in first element allows Obj-c code to pass an array of parameters since the variadic parameters don't map correctly from Obj-c to swift
    var params = paramArray
    if let firstElement = paramArray.first as? Array<Any> {
      params = firstElement
    }
    let statement = StatementParts(sql: query, values: params, type: .query)

    do {
      try DBManager.executeStatement(statement) { (result) in
        guard let result = result else { return }
        while result.next() {
          let newInstance = ModelType()
          populateInstance(result: result, updateInstance: newInstance)
          instances.append(newInstance)
        }
      }
    } catch {
      print("Error executing instances query (\(query)): \(error)")
    }
    return instances
  }

  public static func numberOfInstancesWhere(_ whereClause: String?, params: Any...) -> Int {
    var count = 0

    var query = "SELECT COUNT(*) FROM \(sqlTableName)"
    if let whereClause = whereClause {
      query += " WHERE \(whereClause)"
    }
    let statement = StatementParts(sql: query, values: params, type: .query)

    do {
      try DBManager.executeStatement(statement) { (result) in
        guard let result = result else { return }
        while result.next() {
          count = Int(result.int(forColumnIndex: 0))
          break
        }
      }
    } catch {
      print("Failed to get numberOfInstancesWhere: \(error)")
    }
    return count
  }

  public static func deleteAllInstances() {
    deleteInstances(whereClause: nil, params: [])
  }

  public static func deleteWhere(_ whereClause: String, params: Any...) {
    deleteInstances(whereClause: whereClause, params: params)
  }

  private static func deleteInstances(whereClause: String? = nil, params: Array<Any>) {
    var query = "DELETE FROM \(sqlTableName)"
    if let whereClause = whereClause {
      query += " WHERE \(whereClause)"
    }
    let statement = StatementParts(sql: query, values: params, type: .update)

    do {
      try DBManager.executeStatement(statement) { _ in }
    } catch {
      print("Failed to delete objects from table \(sqlTableName): \(error)")
    }
  }

  //MARK: Instance level helpers

  public func createSaveStatement() -> StatementParts {
    var values = [Any]()
    let sqlTableName = type(of: self).sqlTableName
    let columns = type(of: self).columns

    switch existsInDatabase {
      case true: //Update
        do {
          let primaryKeyData = try getKeyData(constraint: .primary)
          
          var setClauses = [String]()
          
          for meta in type(of: self).columns {
            if !meta.constraint.contains(.primary) {
              let val = getValueToWriteToDB(meta)
              if let val = val as? NSObject , val == NSNull() {
                setClauses.append("\(meta.name) = NULL")
                
              } else {
                values.append(val)
                setClauses.append("\(meta.name) = ?")
              }
            }
          }
          
          values.append(contentsOf: primaryKeyData.values)
          return StatementParts(sql: "UPDATE \(sqlTableName) SET \(setClauses.joined(separator: ",")) WHERE \(primaryKeyData.whereClause)", values: values, type: .update)
          
        } catch QueryError.keyIsNull(let name) {
          preconditionFailure("Primary key field '\(name)' must contain a value: \(sqlTableName)")
          
        } catch QueryError.missingKey {
          preconditionFailure("Primary key field must be defined for table: \(sqlTableName)")
          
        } catch {
          preconditionFailure("Error creating update statement: \(error)")
        }

      case false: //New Instance
        var names = [String]()
        var valueHolders = [String]()

        for meta in columns {
          let val = getValueToWriteToDB(meta)
          values.append(val)
          names.append(meta.name)
          valueHolders.append("?")
        }

        let insertPrefix = DBManager.shouldReplaceDuplicates ? "INSERT OR REPLACE" : "INSERT"
        return StatementParts(sql: "\(insertPrefix) INTO \(sqlTableName) (\(names.joined(separator: ","))) VALUES (\(valueHolders.joined(separator: ",")))", values: values, type: .update)
    }
  }

  public func save() {
    let localTableName = type(of: self).sqlTableName
    let statement = createSaveStatement()

    do {
      try DBManager.executeStatement(statement) { (result) in
        self.existsInDatabase = true
      }

    } catch QueryError.failed(let code) {
      if code == 19 && !self.existsInDatabase { //unique constraint error on adding new object
        do {
          let uniqueKeyData = try self.getKeyData(constraint: .unique, fallbackConstraint: .primary)
          print("Update object with data that already exists in the db for '\(localTableName)'. \(uniqueKeyData.whereClause) >> \(uniqueKeyData.values)")
          self.reloadWithData(uniqueKeyData)
          
        } catch QueryError.missingKey {
          preconditionFailure("Failed to load duplicate object from db because no unique key defined: \(localTableName)")
          
        } catch QueryError.keyIsNull(let name) {
          print("Failed to load duplicate object from db because missing unique key value: \(localTableName).\(name)")
          
        } catch {
          print("Failed to update duplicate object: \(error)")
        }
      }

    } catch {
      print("Failed to \(self.existsInDatabase ? "update" : "insert") object: \(error)")
    }
  }

  public func reload() {
    precondition(existsInDatabase, "Can't reload an object that doesn't yet exist in the database.")
    
    do {
      let primaryKeyData = try getKeyData(constraint: .primary)
      reloadWithData(primaryKeyData)
      
    } catch QueryError.missingKey {
      preconditionFailure("Every table must define one or more primary key columns: \(type(of: self).sqlTableName)")
      
    } catch QueryError.keyIsNull(let name) {
      preconditionFailure("Primary key field '\(name)' must contain a value: \(type(of: self).sqlTableName)")
      
    } catch {
      preconditionFailure("Failed to reload: \(error)")
    }
  }

  public func delete() {
    if !existsInDatabase {
      return
    }
    
    let localTableName = type(of: self).sqlTableName
    do {
      let primaryKeyData = try getKeyData(constraint: .primary)
      let statement = StatementParts(sql: "DELETE FROM \(localTableName) WHERE \(primaryKeyData.whereClause)", values: primaryKeyData.values, type: .update)
      
      try DBManager.executeStatement(statement) { _ in }
      self.isDeleted = true
      
    } catch QueryError.missingKey {
      preconditionFailure("Every table must define one or more primary key columns: \(type(of: self).sqlTableName)")
      
    } catch QueryError.keyIsNull(let name) {
      preconditionFailure("Primary key field '\(name)' must contain a value: \(type(of: self).sqlTableName)")
      
    } catch {
      print("Failed to delete object from table \(localTableName): \(error)")
    }
    
    (self as? ModelType)?.didDelete()
  }

  //MARK: Private helpers
  
  fileprivate func reloadWithData(_ keyData: KeyData) {
    do {
      let statement = StatementParts(
        sql: "SELECT * FROM \(type(of: self).sqlTableName) WHERE \(keyData.whereClause) LIMIT 1",
        values: keyData.values,
        type: .query)
      try DBManager.executeStatement(statement, resultHandler: { (result) in
        guard let result = result else {
          print("Failed to reload object from db cache")
          return
        }
        
        var foundMatch = false
        while result.next() {
          type(of: self).populateInstance(result: result, updateInstance: self as! ModelType)
          foundMatch = true
        }
        
        if !foundMatch {
          self.isDeleted = true
        }
      })
    } catch {
      print("Failed to reload object: \(error)")
    }
  }

  private func getValueToWriteToDB(_ meta: ColumnMeta) -> Any {
    var val: Any = self.value(forKey: meta.name) ?? NSNull()

    switch meta.type {
      case .array:
        if let a = val as? Array<AnyObject> {
          do {
            let data = try PropertyListSerialization.data(fromPropertyList: a, format: PropertyListSerialization.PropertyListFormat.binary, options: 0)
            val = data
          } catch {
            preconditionFailure("Unable to serialize array for \(type(of: self).sqlTableName).\(meta.name): \(error)")
          }
        }
      case .dictionary:
        if let d = val as? ResultDictionary {
          do {
            let data = try PropertyListSerialization.data(fromPropertyList: d, format: PropertyListSerialization.PropertyListFormat.binary, options: 0)
            val = data
          } catch {
            preconditionFailure("Unable to serialize dictionary for \(type(of: self).sqlTableName).\(meta.name): \(error)")
          }
        }
      default:
        break
    }
    return val
  }
  
  fileprivate func getKeyData(constraint: ColumnConstraint, fallbackConstraint: ColumnConstraint? = nil) throws -> KeyData {
    func readKeyData(constraint: ColumnConstraint) throws -> KeyData {
      var keys = Array<ColumnMeta>()
      var values = Array<Any>()
      
      for meta in type(of: self).columns {
        if meta.constraint.contains(constraint) {
          guard let keyValue = self.value(forKey: meta.name) else {
            throw QueryError.keyIsNull(fieldName: meta.name)
          }
          keys.append(meta)
          values.append(keyValue)
        }
      }
      guard keys.count > 0 else {
        throw QueryError.missingKey
      }
      
      let whereClause = keys.map({ (key) -> String in
        return "\(key.name) = ?"
      }).joined(separator: " AND ")
      
      return KeyData(whereClause: whereClause, values: values, columns: keys)
    }
    
    do {
      let keyData = try readKeyData(constraint: constraint)
      return keyData
      
    } catch {
      if let fallbackConstraint = fallbackConstraint {
        return try readKeyData(constraint: fallbackConstraint)
      } else {
        throw error
      }
    }
  }

  private static func populateInstance(result: FMResultSet, updateInstance: ModelType) -> Void {
    updateInstance.existsInDatabase = true

    for meta in columns {
      switch meta.type {
        case .text:
          let val = result.string(forColumn: meta.name)
          updateInstance.setValue(val, forKey: meta.name)
        case .int:
          let val = Int(result.int(forColumn: meta.name))
          updateInstance.setValue(val, forKey: meta.name)
        case .bool:
          let val = result.bool(forColumn: meta.name)
          updateInstance.setValue(val, forKey: meta.name)
        case .real:
          let val = Double(result.double(forColumn: meta.name))
          updateInstance.setValue(val, forKey: meta.name)
        case .date:
          let val = Double(result.long(forColumn: meta.name))
          let d = Date(timeIntervalSince1970: val)
          updateInstance.setValue(d, forKey: meta.name)

        case .array:
          var arrayVal = [Any]()
          guard let data = result.data(forColumn: meta.name) else {
            updateInstance.setValue(arrayVal, forKey: meta.name)
            continue
          }

          do {
            if let a = try PropertyListSerialization.propertyList(
              from: data, options: PropertyListSerialization.MutabilityOptions(),
              format: nil) as? Array<Any>
            {
              arrayVal = a
            } else {
              preconditionFailure("Unable to deserialize array for \(sqlTableName).\(meta.name): Was nil or couldn't be cast as Array<String>")
            }
          } catch {
            preconditionFailure("Unable to deserialize array for \(sqlTableName).\(meta.name): \(error)")
          }
          updateInstance.setValue(arrayVal, forKey: meta.name)

        case .dictionary:
          var dictVal = ResultDictionary()
          guard let data = result.data(forColumn: meta.name) else {
            updateInstance.setValue(dictVal, forKey: meta.name)
            continue
          }

          do {
            if let d = try PropertyListSerialization.propertyList(
              from: data,
              options: PropertyListSerialization.MutabilityOptions(),
              format: nil) as? ResultDictionary
            {
              dictVal = d
            } else {
              preconditionFailure("Unable to deserialize dictionary for \(sqlTableName).\(meta.name): Was nil or couldn't be cast as ResultDictionary")
            }
          } catch {
            preconditionFailure("Unable to deserialize dictionary for \(sqlTableName).\(meta.name): \(error)")
          }
          updateInstance.setValue(dictVal, forKey: meta.name)
      }
    }
  }
}
