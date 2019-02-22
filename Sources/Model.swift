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
   The `primaryKeys` are required to contain one or more columns that are used to uniquely
   identify an object in the database table and are required to have values.
   */
  var primaryKeys: Array<CodingKey> { get }
  /**
   The `secondaryKeys` define set of columns that can be used to uniquely identify a row in the table but
   columns may contain null values. Server generated keys are often used as `secondaryKeys` to avoid
   duplicate database entries, but still allow for objects to be created locally without a server generated id value.
   */
  var secondaryKeys: Array<CodingKey> { get }
}

/**
 Adopting this protocol will ensure that local changes to an object are not overwritten by attempted
 inserts that result in secondary key violations.  If the object is showing as synced
 (syncStatus == syncInFlightStatus == .synced) then it will still be updated with the data from the insert.
 */
public protocol SyncableModel {
  var syncStatus: DataStatus { get set }
  var syncInFlightStatus: DataStatus { get set }
}

public enum DataStatus: Int, Codable {
  case localOnly = 1, dirty, synced, deleted, temporary, ignore
}

extension ModelDef {
  public static func generateUUID() -> String {
    return UUID().uuidString
  }
  
  //MARK: Helper methods for storing arrays/dictionary values to the database.  This allows a ModelDef object to have properties of type Array/Dictionary.
  public static func dataToArray(_ data: Data?) throws -> Array<Dictionary<String,Any>>? {
    guard let data = data else {
      return nil
    }
    guard let a = try PropertyListSerialization.propertyList(from: data, options: PropertyListSerialization.MutabilityOptions(), format: nil) as? Array<Dictionary<String,Any>> else {
      Log.error("Error converting data to an array")
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
      Log.error("Error converting data to a dictionary")
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
    let statement = createReadFirstInstance(whereClause: whereClause, params: params)
    let instances = fetchInstances(statement: statement)
    return instances.first
  }
  
  public static func instances(_ query: String, params: Any...) -> Array<ModelType> {
    return fetchInstances(statement: createReadInstances(query: query, params: params))
  }
  
  public static func instancesWhere(_ whereClause: String, params: Any...) -> Array<ModelType> {
    return fetchInstances(statement: createReadInstances(whereClause: whereClause, params: params))
  }
  
  public static func instancesOrderedBy(_ orderByClause: String) -> Array<ModelType> {
    return fetchInstances(statement: createReadInstances(orderedBy: orderByClause))
  }

  public static func allInstances() -> Array<ModelType> {
    return fetchInstances(statement: createReadAllInstances())
  }
  
  private static func fetchInstances(statement: StatementParts) -> Array<ModelType> {
    var instances = [ModelType]()
    
    do {
      try DBManager.executeStatement(statement) { (result) in
        guard let result = result else { return }
        while result.next() {
          do {
            let newInstance = try ModelType(fromSQL: SQLDecoder(result: result))
            instances.append(newInstance)
          } catch {
            Log.error("Error creating instance from db result: \(error)")
          }
        }
      }
    } catch {
      Log.error("Error executing instances query (\(statement.sql)): \(error)")
    }
    return instances
  }
  
  public static func createReadFirstInstance(whereClause: String, params: Any...) -> StatementParts {
    let query = "SELECT * FROM \(tableName) WHERE \(whereClause) LIMIT 1"
    return createFetchInstances(query: query, paramArray: params)
  }
  
  public static func createReadInstances(query: String, params: Any...) -> StatementParts {
    return createFetchInstances(query: query, paramArray: params)
  }
  
  public static func createReadInstances(whereClause: String, params: Any...) -> StatementParts {
    let query = "SELECT * FROM \(tableName) WHERE \(whereClause)"
    return createFetchInstances(query: query, paramArray: params)
  }
  
  public static func createReadInstances(orderedBy: String) -> StatementParts {
    let query = "SELECT * FROM \(tableName) ORDER BY \(orderedBy)"
    return createFetchInstances(query: query, paramArray: [])
  }
  
  public static func createReadAllInstances() -> StatementParts {
    let query = "SELECT * FROM \(tableName)"
    return createFetchInstances(query: query, paramArray: [])
  }
  
  private static func createFetchInstances(query: String, paramArray: Array<Any>) -> StatementParts {
    //Checking for an array in first element allows Obj-c code to pass an array of parameters since the variadic parameters don't map correctly from Obj-c to swift
    //To allow both the instance* and create* methods to use variadic parameters, paramArray might be a doubly nested array we need to unwrap
    var params = paramArray
    if let firstElement = paramArray.first as? Array<Any> {
      if let nextFirst = firstElement.first as? Array<Any> {
        params = nextFirst
      } else {
        params = firstElement
      }
    }
    let statement = StatementParts(sql: query, values: params, type: .query)
    return statement
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
      Log.error("Failed to get numberOfInstancesWhere: \(error)")
    }
    return count
  }

  public static func deleteAllInstances() {
    deleteInstances(whereClause: nil, params: [])
  }
  
  public static func createDeleteAllStatement() -> StatementParts {
    return createDeleteStatement(whereClause: nil, params: [])
  }

  public static func deleteWhere(_ whereClause: String, params: Any...) {
    deleteInstances(whereClause: whereClause, params: params)
  }
  
  public static func createDeleteWhere(_ whereClause: String, params: Any...) -> StatementParts {
    return createDeleteStatement(whereClause: whereClause, params: params)
  }

  private static func deleteInstances(whereClause: String? = nil, params: Array<Any>) {
    do {
      let statement = createDeleteStatement(whereClause: whereClause, params: params)
      try DBManager.executeStatement(statement) { _ in }
    } catch {
      Log.error("Failed to delete objects from table \(tableName): \(error)")
    }
  }
  
  private static func createDeleteStatement(whereClause: String? = nil, params: Array<Any>) -> StatementParts {
    var query = "DELETE FROM \(tableName)"
    if let whereClause = whereClause {
      query += " WHERE \(whereClause)"
    }
    let statement = StatementParts(sql: query, values: params, type: .update)
    return statement
  }
  
  public func createDeleteStatement() throws -> StatementParts {
    guard let elements = try? SQLEncoder.encode(self) else {
      throw ModelError<ModelType>.invalidObject
    }
    let values = elements.primaryKeys.compactMap { $0.value }
    let clauses = elements.primaryKeys.map{ $0.predicate }
    let statement = type(of: self).createDeleteStatement(whereClause: clauses.joined(separator: " AND "), params: values)
    return statement
  }

  //MARK: Instance level helpers
  
  public func createSaveStatement() throws -> StatementParts {
    guard let elements = try? SQLEncoder.encode(self) else {
      throw ModelError<ModelType>.invalidObject
    }
    return try createSaveStatement(elements)
  }
  
  private func computeParts(_ elements: SQLElements) throws -> Parts {
    guard primaryKeys.count > 0 else {
      throw QueryError.missingKey
    }
    
    var parts = Parts()
    
    for column in elements.columns {
      if let value = column.value {
        parts.insertNames.append(column.name)
        parts.insertPlaceholders.append("?")
        parts.insertValues.append(value)
      }
      
      if column.isPrimaryKey {
        parts.primaryKeyPredicates.append(column.predicate)
        guard let value = column.value else {
          throw QueryError.keyIsNull(fieldName: column.name)
        }
        parts.primaryKeyValues.append(value)
        
      } else if column.isSecondaryKey {
        parts.primaryUpdatePredicates.append(column.predicate)
        guard let value = column.value else {
          parts.canDoSecondary = false
          continue
        }
        parts.primaryUpdateValues.append(value)
        
        parts.secondaryKeyPredicates.append(column.predicate)
        parts.secondaryKeyValues.append(value)
        
      } else { //non key column
        parts.primaryUpdatePredicates.append(column.predicate)
        if let value = column.value {
          parts.primaryUpdateValues.append(value)
        }
        parts.secondaryUpdatePredicates.append(column.predicate)
        if let value = column.value {
          parts.secondaryUpdateValues.append(value)
        }
        if elements.syncable && column.name != "syncStatus" && column.name != "syncInFlightStatus" {
          parts.secondarySyncableUpdatePredicates.append(column.predicate)
          if let value = column.value {
            parts.secondarySyncableUpdateValues.append(value)
          }
        }
      }
    }
    
    return parts
  }

  private func createSaveStatement(_ elements: SQLElements) throws -> StatementParts {
    do {
      guard elements.primaryKeys.count > 0 else {
        throw QueryError.missingKey
      }
      guard !elements.syncable || elements.secondaryKeys.count > 0 else {
        throw QueryError.syncableRequiresSecondaryKey
      }
      let parts = try computeParts(elements)
      
      //Generate all the SQL statements that might be used by the DBManager
      if DBManager.blindlyReplaceDuplicates {
        let insertStatement = StatementParts(sql: "INSERT OR REPLACE INTO \(elements.tableName) (\(parts.insertNames.joined(separator: ","))) VALUES (\(parts.insertPlaceholders.joined(separator: ",")))", values: parts.insertValues, type: .insert)
        return insertStatement
        
      } else {
        let updateByPrimaryKey = StatementParts(sql: "UPDATE \(elements.tableName) SET \(parts.primaryUpdatePredicates.joined(separator: ",")) WHERE \(parts.primaryKeyPredicates.joined(separator: " AND "))", values: parts.primaryUpdateValues + parts.primaryKeyValues, type: .update)
        let selectByPrimaryKey = StatementParts(sql: "SELECT * FROM \(elements.tableName) WHERE \(parts.primaryKeyPredicates.joined(separator: " AND ")) LIMIT 1", values: parts.primaryKeyValues, type: .query)
        
        var updateBySecondaryKey: StatementParts? = nil
        var selectBySecondaryKey: StatementParts? = nil
        if parts.canDoSecondary && elements.secondaryKeys.count > 0 {
          updateBySecondaryKey = StatementParts(sql: "UPDATE \(elements.tableName) SET \(parts.secondaryUpdatePredicates.joined(separator: ",")) WHERE \(parts.secondaryKeyPredicates.joined(separator: " AND "))", values: parts.secondaryUpdateValues + parts.secondaryKeyValues, type: .update)
          selectBySecondaryKey = StatementParts(sql: "SELECT * FROM \(elements.tableName) WHERE \(parts.secondaryKeyPredicates.joined(separator: " AND ")) LIMIT 1", values: parts.secondaryKeyValues, type: .query)
        }
        var updateSyncableBySecondaryKey: StatementParts? = nil
        var selectSyncableBySecondaryKey: StatementParts? = nil
        if elements.syncable && parts.canDoSecondary && elements.secondaryKeys.count > 0 {
          updateSyncableBySecondaryKey = StatementParts(sql: "UPDATE \(elements.tableName) SET \(parts.secondarySyncableUpdatePredicates.joined(separator: ",")) WHERE \(parts.secondaryKeyPredicates.joined(separator: " AND "))", values: parts.secondarySyncableUpdateValues + parts.secondaryKeyValues, type: .update)
          selectSyncableBySecondaryKey = StatementParts(sql: "SELECT * FROM \(elements.tableName) WHERE \(parts.secondaryKeyPredicates.joined(separator: " AND ")) AND syncStatus = ? AND syncInFlightStatus = ? LIMIT 1", values: parts.secondaryKeyValues + [DataStatus.synced.rawValue, DataStatus.synced.rawValue], type: .query)
        }
        
        let type = StatementType.save(syncable: elements.syncable, updateByPrimaryKey: updateByPrimaryKey, selectByPrimaryKey: selectByPrimaryKey, updateBySecondaryKey: updateBySecondaryKey, selectBySecondaryKey: selectBySecondaryKey, updateSyncableBySecondaryKey: updateSyncableBySecondaryKey, selectSyncableBySecondaryKey: selectSyncableBySecondaryKey)
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
      var resultState: ResultState = .failed
      try DBManager.executeStatements([statement]) { results, states in
        guard results.count == states.count else {
          preconditionFailure("These counts should always be the same")
        }
        resultState = states[0]
        if let result = results[0] { //did an update so parse out the database instance
          Log.debug("Updated row in db instead of insert: '\(elements.tableName)': primaryKeys=\(elements.primaryKeys): secondaryKeys=\(elements.secondaryKeys)')")
          while result.next() {
            updatedInstance = try? ModelType(fromSQL: SQLDecoder(result: result))
          }
        }
      }
      
      if let updatedInstance = updatedInstance {
        switch resultState {
        case .wouldCreateDuplicate:
          throw ModelError<ModelType>.wouldCreateDuplicate(existingItem: updatedInstance)
        case .duplicateExists:
          throw ModelError<ModelType>.duplicate(existingItem: updatedInstance)
        case .failed: break
        case .success: break
        }
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
      let values = elements.primaryKeys.compactMap { $0.value }
      let clauses = elements.primaryKeys.map{ $0.predicate }
      
      let statement = StatementParts(
        sql: "SELECT * FROM \(type(of: self).tableName) WHERE \(clauses.joined(separator: " AND ")) LIMIT 1",
        values: values,
        type: .query)
      
      try DBManager.executeStatement(statement, resultHandler: { (result) in
        do {
          guard let result = result else {
            Log.warn("Failed to reload object from db cache")
            return
          }
          
          while result.next() {
            newInstance = try ModelType(fromSQL: SQLDecoder(result: result))
          }
        } catch {
          Log.warn("Unable to reload object: \(error)")
        }
      })
      return newInstance
      
    } catch QueryError.missingKey {
      preconditionFailure("Every table must define one or more primary key columns: \(type(of: self).tableName)")
      
    } catch QueryError.keyIsNull(let name) {
      preconditionFailure("Primary key field '\(name)' must contain a value: \(type(of: self).tableName)")
      
    } catch {
      Log.error("Failed to reload: \(error)")
      return nil
    }
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
      Log.warn("Failed to delete object from table \(type(of: self).tableName): \(error)")
    }
  }

  //MARK: Private helpers
  
  fileprivate func readFromDB(_ keyColumns: Array<SQLColumn>) throws -> ModelType? {
    var newInstance: ModelType? = nil
    let values = keyColumns.compactMap { $0.value }
    let clauses = keyColumns.map{ $0.predicate }
    
    let statement = StatementParts(
          sql: "SELECT * FROM \(type(of: self).tableName) WHERE \(clauses.joined(separator: " AND ")) LIMIT 1",
          values: values,
          type: .query)
    
    try DBManager.executeStatement(statement, resultHandler: { (result) in
      do {
        guard let result = result else {
          Log.warn("Failed to reload object from db cache")
          return
        }
        
        while result.next() {
          newInstance = try ModelType(fromSQL: SQLDecoder(result: result))
        }
      } catch {
        Log.warn("Unable to reload object: \(error)")
      }
    })
    
    return newInstance
  }
}

fileprivate struct Parts {
  var insertNames = [String]()
  var insertPlaceholders = [String]()
  var insertValues = [Any]()
  
  var primaryUpdatePredicates = [String]()
  var primaryUpdateValues = [Any]()
  var primaryKeyPredicates = [String]()
  var primaryKeyValues = [Any]()
  
  var canDoSecondary = true
  var secondaryUpdatePredicates = [String]()
  var secondaryUpdateValues = [Any]()
  var secondaryKeyPredicates = [String]()
  var secondaryKeyValues = [Any]()
  
  var secondarySyncableUpdatePredicates = [String]()
  var secondarySyncableUpdateValues = [Any]()
}
