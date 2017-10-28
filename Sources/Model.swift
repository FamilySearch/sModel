import Foundation
import FMDB

public typealias ResultDictionary = Dictionary<String, Any>

public protocol ModelDef: SQLCodable {
  associatedtype ModelType: SQLCodable
  /**
   Name of the database table that should be used to persist/read objects of this type.
   */
  static var tableName: String { get }
  /**
   This flag influences how constraint violations are handled when inserting objects into the db.  If true, the data already in the database will remain unchanged.  If false, the non-key data in the database will be updated with the object being inserted.
   */
  static var syncable: Bool { get }
  /**
   The `primaryKeys` are required to contain one or more columns that are used to uniquely identify an object in the database table and are required to have values.
   */
  var primaryKeys: Array<CodingKey> { get }
  /**
   The `secondaryKeys` define set of columns that can be used to uniquely identify a row in the table but columns may contain null values. Server generated keys are often used as `secondaryKeys` to avoid duplicate database entries, but still allow for
   objects to be created locally without a server generated id value.
   */
  var secondaryKeys: Array<CodingKey> { get }
}

extension ModelDef {
  
  public static func generateUUID() -> String {
    return UUID().uuidString
  }
  
  public static func dataToArray(_ data: Data?) throws -> Array<Dictionary<String,Any>>? {
    guard let data = data else {
      return nil
    }
    guard let a = try PropertyListSerialization.propertyList(from: data, options: PropertyListSerialization.MutabilityOptions(), format: nil) as? Array<Dictionary<String,Any>> else {
      print("Error converting data to an array")
      throw ModelError<ModelType>.invalidObject
    }
    return a
  }
  
  public static func arrayToData(_ array: Array<Dictionary<String,Any>>?) throws -> Data? {
    guard let array = array else {
      return nil
    }
    let data = try PropertyListSerialization.data(fromPropertyList: array, format: PropertyListSerialization.PropertyListFormat.binary, options: 0)
    return data
  }
  
  public static func dataToDictionary(_ data: Data?) throws -> Dictionary<String,Any>? {
    guard let data = data else {
      return nil
    }
    guard let d = try PropertyListSerialization.propertyList(from: data, options: PropertyListSerialization.MutabilityOptions(), format: nil) as? Dictionary<String,Any> else {
      print("Error converting data to a dictionary")
      throw ModelError<ModelType>.invalidObject
    }
    return d
  }
  
  public static func dictionaryToData(_ dictionary: Dictionary<String,Any>?) throws -> Data? {
    guard let dictionary = dictionary else {
      return nil
    }
    let data = try PropertyListSerialization.data(fromPropertyList: dictionary, format: PropertyListSerialization.PropertyListFormat.binary, options: 0)
    return data
  }

  //MARK: Convenience methods for getting data out of db
  public static func firstInstanceWhere(_ whereClause: String, params: Any...) -> ModelType? {
    let query = "SELECT * FROM \(tableName) WHERE \(whereClause) LIMIT 1"
    let instances = fetchInstances(query: query, paramArray: params)
    return instances.first
  }

  public static func instances(_ query: String, params: Any...) -> Array<ModelType> {
    return fetchInstances(query: query, paramArray: params)
  }

  public static func instancesWhere(_ whereClause: String, params: Any...) -> Array<ModelType> {
    let query = "SELECT * FROM \(tableName) WHERE \(whereClause)"
    return fetchInstances(query: query, paramArray: params)
  }

  public static func instancesOrderedBy(_ orderByClause: String) -> Array<ModelType> {
    let query = "SELECT * FROM \(tableName) ORDER BY \(orderByClause)"
    return fetchInstances(query: query, paramArray: [])
  }

  public static func allInstances() -> Array<ModelType> {
    let query = "SELECT * FROM \(tableName)"
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
          do {
            let newInstance = try ModelType(fromSQL: SQLDecoder(result: result))
            instances.append(newInstance)
          } catch {
            print("Error creating instance from db result: \(error)")
          }
        }
      }
    } catch {
      print("Error executing instances query (\(query)): \(error)")
    }
    return instances
  }

  public static func numberOfInstancesWhere(_ whereClause: String?, params: Any...) -> Int {
    var count = 0

    var query = "SELECT COUNT(*) FROM \(tableName)"
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
    var query = "DELETE FROM \(tableName)"
    if let whereClause = whereClause {
      query += " WHERE \(whereClause)"
    }
    let statement = StatementParts(sql: query, values: params, type: .update)

    do {
      try DBManager.executeStatement(statement) { _ in }
    } catch {
      print("Failed to delete objects from table \(tableName): \(error)")
    }
  }

  //MARK: Instance level helpers
  
  public func createSaveStatement() throws -> StatementParts {
    guard let elements = try? SQLEncoder.encode(self) else {
      throw ModelError<ModelType>.invalidObject
    }
    return try createSaveStatement(elements)
  }

  private func createSaveStatement(_ elements: SQLElements) throws -> StatementParts {
    func computeParts() throws -> (insertNames: [String], insertPlaceholders: [String], insertValues: [Any],
                                   primaryUpdateSets: [String], primaryUpdateValues: [Any], primaryKeySets: [String], primaryKeyValues: [Any],
                                   canDoSecondary: Bool, secondaryUpdateSets: [String], secondaryUpdateValues: [Any], secondaryKeySets: [String], secondaryKeyValues: [Any])
    {
      var insertNames = [String]()
      var insertPlaceholders = [String]()
      var insertValues = [Any]()
      
      var primaryUpdateSets = [String]()
      var primaryUpdateValues = [Any]()
      var primaryKeySets = [String]()
      var primaryKeyValues = [Any]()
      
      var canDoSecondary = true
      var secondaryUpdateSets = [String]()
      var secondaryUpdateValues = [Any]()
      var secondaryKeySets = [String]()
      var secondaryKeyValues = [Any]()

      for column in elements.columns {
        if let value = column.value {
          insertNames.append(column.name)
          insertPlaceholders.append("?")
          insertValues.append(value)
        }
        
        if column.isPrimaryKey {
          primaryKeySets.append(column.clause)
          guard let value = column.value else {
            throw QueryError.keyIsNull(fieldName: column.name)
          }
          primaryKeyValues.append(value)
          
        } else if column.isSecondaryKey {
          primaryUpdateSets.append(column.clause)
          guard let value = column.value else {
            canDoSecondary = false
            continue
          }
          primaryUpdateValues.append(value)
          
          secondaryKeySets.append(column.clause)
          secondaryKeyValues.append(value)

        } else { //non key column
          primaryUpdateSets.append(column.clause)
          if let value = column.value {
            primaryUpdateValues.append(value)
          }
          secondaryUpdateSets.append(column.clause)
          if let value = column.value {
            secondaryUpdateValues.append(value)
          }
        }
      }
      
      guard primaryKeys.count > 0 else {
        throw QueryError.missingKey
      }
      
      return (insertNames, insertPlaceholders, insertValues,
              primaryUpdateSets, primaryUpdateValues, primaryKeySets, primaryKeyValues,
              canDoSecondary, secondaryUpdateSets, secondaryUpdateValues, secondaryKeySets, secondaryKeyValues)
    }

    do {
      guard elements.primaryKeys.count > 0 else {
        throw QueryError.missingKey
      }
      guard !elements.syncable || elements.secondaryKeys.count > 0 else {
        throw QueryError.syncableRequiresSecondaryKey
      }
      let parts = try computeParts()
      
      if DBManager.blindlyReplaceDuplicates {
        let insertStatement = StatementParts(sql: "INSERT OR REPLACE INTO \(elements.tableName) (\(parts.insertNames.joined(separator: ","))) VALUES (\(parts.insertPlaceholders.joined(separator: ",")))", values: parts.insertValues, type: .insert)
        return insertStatement
        
      } else {
        let updatePrimary = StatementParts(sql: "UPDATE \(elements.tableName) SET \(parts.primaryUpdateSets.joined(separator: ",")) WHERE \(parts.primaryKeySets.joined(separator: " AND "))", values: parts.primaryUpdateValues + parts.primaryKeyValues, type: .update)
        let selectPrimary = StatementParts(sql: "SELECT * FROM \(elements.tableName) WHERE \(parts.primaryKeySets.joined(separator: " AND ")) LIMIT 1", values: parts.primaryKeyValues, type: .query)
        
        var updateSecondary: StatementParts? = nil
        var selectSecondary: StatementParts? = nil
        if parts.canDoSecondary && elements.secondaryKeys.count > 0 {
          updateSecondary = StatementParts(sql: "UPDATE \(elements.tableName) SET \(parts.secondaryUpdateSets.joined(separator: ",")) WHERE \(parts.secondaryKeySets.joined(separator: " AND "))", values: parts.secondaryUpdateValues + parts.secondaryKeyValues, type: .update)
          selectSecondary = StatementParts(sql: "SELECT * FROM \(elements.tableName) WHERE \(parts.secondaryKeySets.joined(separator: " AND ")) LIMIT 1", values: parts.secondaryKeyValues, type: .query)
        }
        
        let type = StatementType.save(syncable: elements.syncable, updatePrimary: updatePrimary, selectPrimary: selectPrimary, updateSecondary: updateSecondary, selectSecondary: selectSecondary)
        let insertStatement = StatementParts(sql: "INSERT OR IGNORE INTO \(elements.tableName) (\(parts.insertNames.joined(separator: ","))) VALUES (\(parts.insertPlaceholders.joined(separator: ",")))", values: parts.insertValues, type: type)
        return insertStatement
      }
      

    } catch QueryError.keyIsNull(let name) {
      preconditionFailure("Primary key field '\(name)' must contain a value: \(elements.tableName)")
      
    } catch QueryError.missingKey {
      preconditionFailure("Primary key field must be defined for table: \(elements.tableName)")
      
    } catch {
      preconditionFailure("Error creating insert/update statement: \(error)")
    }
  }

  public func save() throws {
    guard let elements = try? SQLEncoder.encode(self) else {
      throw ModelError<ModelType>.invalidObject
    }
    
    do {
      let statement = try createSaveStatement(elements)
      var updatedInstance: ModelType?
      try DBManager.executeStatements([statement]) { results in
        if let result = results[0] { //did an update
          print("Updated row in db instead of insert: '\(elements.tableName)': primaryKeys=\(elements.primaryKeys): secondaryKeys=\(elements.secondaryKeys)')")
          while result.next() {
            updatedInstance = try? ModelType(fromSQL: SQLDecoder(result: result))
          }
        }
      }
      
      if let updatedInstance = updatedInstance {
        throw ModelError<ModelType>.duplicate(existingItem: updatedInstance)
      }

    } catch QueryError.missingKey {
      preconditionFailure("Failed to load duplicate object from db because no unique key defined: \(elements.tableName)")
      
    } catch QueryError.keyIsNull(let name) {
      preconditionFailure("Failed to load duplicate object from db because missing unique key value: \(elements.tableName).\(name)")
    }
  }
  
  @available(*, unavailable, message: ".reload is no longer available.  Use `readFromDB` instead.")
  public func reload() {
    preconditionFailure(".reload is no longer available.  Use `readFromDB` instead.")
  }

  public func readFromDB() -> ModelType? {
    do {
      let elements = try SQLEncoder.encode(self)
      var newInstance: ModelType? = nil
      let values = elements.primaryKeys.flatMap { $0.value }
      let clauses = elements.primaryKeys.map{ $0.clause }
      
      let statement = StatementParts(
        sql: "SELECT * FROM \(type(of: self).tableName) WHERE \(clauses.joined(separator: " AND ")) LIMIT 1",
        values: values,
        type: .query)
      
      try DBManager.executeStatement(statement, resultHandler: { (result) in
        do {
          guard let result = result else {
            print("Failed to reload object from db cache")
            return
          }
          
          while result.next() {
            newInstance = try ModelType(fromSQL: SQLDecoder(result: result))
          }
        } catch {
          print("Unable to reload object: \(error)")
        }
      })
      return newInstance
      
    } catch QueryError.missingKey {
      preconditionFailure("Every table must define one or more primary key columns: \(type(of: self).tableName)")
      
    } catch QueryError.keyIsNull(let name) {
      preconditionFailure("Primary key field '\(name)' must contain a value: \(type(of: self).tableName)")
      
    } catch {
      preconditionFailure("Failed to reload: \(error)")
    }
  }

  public func createDeleteStatement() throws -> StatementParts {
    guard let elements = try? SQLEncoder.encode(self) else {
      throw ModelError<ModelType>.invalidObject
    }
    let values = elements.primaryKeys.flatMap { $0.value }
    let clauses = elements.primaryKeys.map{ $0.clause }
    let statement = StatementParts(sql: "DELETE FROM \(elements.tableName) WHERE \(clauses.joined(separator: ","))", values: values, type: .update)
    return statement
  }

  public func delete() {
    do {
      let deleteStatement = try createDeleteStatement()
      try DBManager.executeStatement(deleteStatement) { _ in }
      
    } catch QueryError.missingKey {
      preconditionFailure("Every table must define one or more primary key columns: \(type(of: self).tableName)")
      
    } catch QueryError.keyIsNull(let name) {
      preconditionFailure("Primary key field '\(name)' must contain a value: \(type(of: self).tableName)")
      
    } catch {
      print("Failed to delete object from table \(type(of: self).tableName): \(error)")
    }
  }

  //MARK: Private helpers
  
  fileprivate func readFromDB(_ keyColumns: Array<SQLColumn>) throws -> ModelType? {
    var newInstance: ModelType? = nil
    let values = keyColumns.flatMap { $0.value }
    let clauses = keyColumns.map{ $0.clause }
    
    let statement = StatementParts(
          sql: "SELECT * FROM \(type(of: self).tableName) WHERE \(clauses.joined(separator: " AND ")) LIMIT 1",
          values: values,
          type: .query)
    
    try DBManager.executeStatement(statement, resultHandler: { (result) in
      do {
        guard let result = result else {
          print("Failed to reload object from db cache")
          return
        }
        
        while result.next() {
          newInstance = try ModelType(fromSQL: SQLDecoder(result: result))
        }
      } catch {
        print("Unable to reload object: \(error)")
      }
    })
    
    return newInstance
  }
}
