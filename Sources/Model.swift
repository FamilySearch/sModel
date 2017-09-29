import Foundation
import FMDB

public typealias ResultDictionary = Dictionary<String, Any>

public protocol ModelDef: SQLCodable {
  associatedtype ModelType: SQLCodable
}

extension ModelDef {
  
  public static func generateUUID() -> String {
    return UUID().uuidString
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
      try DBManager.executeStatement(statement) { (result, _) in
        guard let result = result else { return }
        while result.next() {
          do {
            let newInstance = try ModelType(fromSQL: SQLDecoder(data: result))
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
      try DBManager.executeStatement(statement) { (result, _) in
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
      try DBManager.executeStatement(statement) { _, _ in }
    } catch {
      print("Failed to delete objects from table \(tableName): \(error)")
    }
  }

  //MARK: Instance level helpers

  public func createSaveStatements(_ elements: SQLElements) throws -> Array<StatementParts> {
    func computeParts() throws -> (setClauses: Array<String>, primaryKeyClauses: Array<String>, updateValues: Array<Any>, insertNames: Array<String>, insertValueHolders: Array<String>, insertValues: Array<Any>) {
      var updateValues = [Any]()
      var setClauses = [String]()
      var keyClauses = [String]()
      var keyValues = [Any]()
      var insertValues = [Any]()
      var insertNames = [String]()
      var insertValueHolders = [String]()
      let useSecondary = (elements.secondaryKeys.count > 0)
      
      for column in elements.columns {
        if let value = column.value {
          insertNames.append(column.name)
          insertValueHolders.append("?")
          insertValues.append(value)
        }
        
        if column.isPrimaryKey || column.isSecondaryKey {
          guard (useSecondary && column.isSecondaryKey) || (!useSecondary && column.isPrimaryKey) else { //ignore key columns if they aren't part of the keys we are looking at
            continue
          }
          keyClauses.append(column.clause)
          guard let value = column.value else {
            throw QueryError.keyIsNull(fieldName: column.clause)
          }
          keyValues.append(value)
        } else {
          setClauses.append(column.clause)
          if let value = column.value {
            updateValues.append(value)
          }
        }
      }
      return (setClauses, keyClauses, updateValues + keyValues, insertNames, insertValueHolders, insertValues)
    }

    do {
      guard elements.primaryKeys.count > 0 else {
        throw QueryError.missingKey
      }
      let sqlParts = try computeParts()
      
      switch self.existsInDatabase {
      case true: //Update
        return [StatementParts(sql: "UPDATE \(elements.tableName) SET \(sqlParts.setClauses.joined(separator: ",")) WHERE \(sqlParts.primaryKeyClauses.joined(separator: " AND "))", values: sqlParts.updateValues, type: .update)]

      case false: //New Instance
        let insertPrefix = DBManager.shouldReplaceDuplicates ? "INSERT OR REPLACE" : "INSERT OR IGNORE"
        //TODO: We'll still need to throw an exception if the insert fails so they can get a version of the object with the correct primary key (localId)
        let updateStatement = StatementParts(sql: "UPDATE \(elements.tableName) SET \(sqlParts.setClauses.joined(separator: ",")) WHERE \(sqlParts.primaryKeyClauses.joined(separator: " AND "))", values: sqlParts.updateValues, type: .update)
        let type = StatementType.insert(update: updateStatement)
        let insertStatement = StatementParts(sql: "\(insertPrefix) INTO \(elements.tableName) (\(sqlParts.insertNames.joined(separator: ","))) VALUES (\(sqlParts.insertValueHolders.joined(separator: ",")))", values: sqlParts.insertValues, type: type)
        return [insertStatement]
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
      let statements = try createSaveStatements(elements)
      var didUpdate = false
      try DBManager.executeStatements(statements) { results, fallthroughUpdate in
        didUpdate = fallthroughUpdate
      }
      
      if didUpdate {
        print("Updated row in db instead of insert: '\(elements.tableName): \(elements.primaryKeys)')")
        let keyColumns = elements.secondaryKeys.count > 0 ? elements.secondaryKeys : elements.primaryKeys
        let returnItem = try readFromDB(keyColumns)
        throw ModelError<ModelType>.duplicate(existingItem: returnItem)
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
    precondition(existsInDatabase, "Can't reload an object that doesn't yet exist in the database.")
    do {
      let elements = try SQLEncoder.encode(self)
      return try readFromDB(elements.primaryKeys)
      
    } catch QueryError.missingKey {
      preconditionFailure("Every table must define one or more primary key columns: \(type(of: self).tableName)")
      
    } catch QueryError.keyIsNull(let name) {
      preconditionFailure("Primary key field '\(name)' must contain a value: \(type(of: self).tableName)")
      
    } catch {
      preconditionFailure("Failed to reload: \(error)")
    }
  }

  public func delete() {
    if !existsInDatabase {
      return
    }
    
    let localTableName = type(of: self).tableName
    do {
      let elements = try SQLEncoder.encode(self)
      let values = elements.primaryKeys.flatMap { $0.value }
      let clauses = elements.primaryKeys.map{ $0.clause }
      let statement = StatementParts(sql: "DELETE FROM \(localTableName) WHERE \(clauses.joined(separator: ","))", values: values, type: .update)
      
      try DBManager.executeStatement(statement) { _, _ in }
      
    } catch QueryError.missingKey {
      preconditionFailure("Every table must define one or more primary key columns: \(type(of: self).tableName)")
      
    } catch QueryError.keyIsNull(let name) {
      preconditionFailure("Primary key field '\(name)' must contain a value: \(type(of: self).tableName)")
      
    } catch {
      print("Failed to delete object from table \(localTableName): \(error)")
    }
  }

  //MARK: Private helpers
  
  fileprivate func readFromDB(_ keyColumns: Array<SQLColumn>) throws -> ModelType {
    var newInstance: ModelType = self as! ModelType
    let values = keyColumns.flatMap { $0.value }
    let clauses = keyColumns.map{ $0.clause }
    
    let statement = StatementParts(
          sql: "SELECT * FROM \(type(of: self).tableName) WHERE \(clauses.joined(separator: " AND ")) LIMIT 1",
          values: values,
          type: .query)
    
    try DBManager.executeStatement(statement, resultHandler: { (result, _) in
      do {
        guard let result = result else {
          print("Failed to reload object from db cache")
          return
        }
        
        while result.next() {
          newInstance = try ModelType(fromSQL: SQLDecoder(data: result))
        }
      } catch {
        print("Unable to reload object: \(error)")
      }
    })
    
    return newInstance
  }

//  private func getValueToWriteToDB(_ meta: ColumnMeta) -> Any {
//    var val: Any = self.value(forKey: meta.name) ?? NSNull()
//
//    switch meta.type {
//      case .array:
//        if let a = val as? Array<AnyObject> {
//          do {
//            let data = try PropertyListSerialization.data(fromPropertyList: a, format: PropertyListSerialization.PropertyListFormat.binary, options: 0)
//            val = data
//          } catch {
//            preconditionFailure("Unable to serialize array for \(type(of: self).tableName).\(meta.name): \(error)")
//          }
//        }
//      case .dictionary:
//        if let d = val as? ResultDictionary {
//          do {
//            let data = try PropertyListSerialization.data(fromPropertyList: d, format: PropertyListSerialization.PropertyListFormat.binary, options: 0)
//            val = data
//          } catch {
//            preconditionFailure("Unable to serialize dictionary for \(type(of: self).tableName).\(meta.name): \(error)")
//          }
//        }
//      default:
//        break
//    }
//    return val
//  }
  
//  fileprivate func getKeyData(constraint: ColumnConstraint, fallbackConstraint: ColumnConstraint? = nil) throws -> KeyData {
//    func readKeyData(constraint: ColumnConstraint) throws -> KeyData {
//      var keys = Array<ColumnMeta>()
//      var values = Array<Any>()
//
//      for meta in type(of: self).columns {
//        if meta.constraint.contains(constraint) {
//          guard let keyValue = self.value(forKey: meta.name) else {
//            throw QueryError.keyIsNull(fieldName: meta.name)
//          }
//          keys.append(meta)
//          values.append(keyValue)
//        }
//      }
//      guard keys.count > 0 else {
//        throw QueryError.missingKey
//      }
//
//      let whereClause = keys.map({ (key) -> String in
//        return "\(key.name) = ?"
//      }).joined(separator: " AND ")
//
//      return KeyData(whereClause: whereClause, values: values, columns: keys)
//    }
//
//    do {
//      let keyData = try readKeyData(constraint: constraint)
//      return keyData
//
//    } catch {
//      if let fallbackConstraint = fallbackConstraint {
//        return try readKeyData(constraint: fallbackConstraint)
//      } else {
//        throw error
//      }
//    }
//  }

//  public static func populateInstance(result: FMResultSet, updateInstance: T) -> Void {
//    updateInstance.existsInDatabase = true
//
//    for meta in columns {
//      switch meta.type {
//        case .text:
//          let val = result.string(forColumn: meta.name)
//          updateInstance.setValue(val, forKey: meta.name)
//        case .int:
//          let val = Int(result.int(forColumn: meta.name))
//          updateInstance.setValue(val, forKey: meta.name)
//        case .bool:
//          let val = result.bool(forColumn: meta.name)
//          updateInstance.setValue(val, forKey: meta.name)
//        case .real:
//          let val = Double(result.double(forColumn: meta.name))
//          updateInstance.setValue(val, forKey: meta.name)
//        case .date:
//          let val = Double(result.long(forColumn: meta.name))
//          let d = Date(timeIntervalSince1970: val)
//          updateInstance.setValue(d, forKey: meta.name)
//
//        case .array:
//          var arrayVal = [Any]()
//          guard let data = result.data(forColumn: meta.name) else {
//            updateInstance.setValue(arrayVal, forKey: meta.name)
//            continue
//          }
//
//          do {
//            if let a = try PropertyListSerialization.propertyList(
//              from: data, options: PropertyListSerialization.MutabilityOptions(),
//              format: nil) as? Array<Any>
//            {
//              arrayVal = a
//            } else {
//              preconditionFailure("Unable to deserialize array for \(tableName).\(meta.name): Was nil or couldn't be cast as Array<String>")
//            }
//          } catch {
//            preconditionFailure("Unable to deserialize array for \(tableName).\(meta.name): \(error)")
//          }
//          updateInstance.setValue(arrayVal, forKey: meta.name)
//
//        case .dictionary:
//          var dictVal = ResultDictionary()
//          guard let data = result.data(forColumn: meta.name) else {
//            updateInstance.setValue(dictVal, forKey: meta.name)
//            continue
//          }
//
//          do {
//            if let d = try PropertyListSerialization.propertyList(
//              from: data,
//              options: PropertyListSerialization.MutabilityOptions(),
//              format: nil) as? ResultDictionary
//            {
//              dictVal = d
//            } else {
//              preconditionFailure("Unable to deserialize dictionary for \(tableName).\(meta.name): Was nil or couldn't be cast as ResultDictionary")
//            }
//          } catch {
//            preconditionFailure("Unable to deserialize dictionary for \(tableName).\(meta.name): \(error)")
//          }
//          updateInstance.setValue(dictVal, forKey: meta.name)
//      }
//    }
//  }
}
