import Foundation
import FMDB

public enum DBError: Error {
  case openFailed, dbPathInvalid, missingDBQueue, restoreFailed, recreateFailed, pushFailed, popFailed, namespaceConflict,
       invalidDBDefChange(namespace: String)
}

public enum ModelError<T>: Error {
  case invalidObject
  case duplicate(existingItem: T)
  case wouldCreateDuplicate(existingItem: T)
}

public enum ResultState {
  case success
  case failed
  case wouldCreateDuplicate
  case duplicateExists
}

enum QueryError: Error {
  case failed(errorCode: Int)
  case missingKey
  case keyIsNull(fieldName: String)
  case insertUpdateFailed
  case syncableRequiresSecondaryKey
}

public indirect enum StatementType {
  case query
  case insert
  case update
  case save(syncable: Bool, updateByPrimaryKey: StatementParts, selectByPrimaryKey: StatementParts,
            updateBySecondaryKey: StatementParts?, selectBySecondaryKey: StatementParts?,
            updateSyncableBySecondaryKey: StatementParts?, selectSyncableBySecondaryKey: StatementParts?)
}

public struct StatementParts {
  let sql: String
  let values: Array<Any>
  let type: StatementType
  
  public init(sql: String, values: Array<Any>, type: StatementType) {
    self.sql = sql
    self.values = values
    self.type = type
  }
}

public protocol DBDef {
  static var namespace: String { get }
  static var defs: [String] { get }
}

public extension DBDef {
  static func namespaced(name: String) -> String {
    "\(namespace)_\(name)"
  }
}

public struct DBMeta {
  public var queue: FMDatabaseQueue
  public var path: String?
}

@objc
public class DBManager: NSObject {
  /**
   Defines how the system will handle database inserts.
   
   If false, the system will use `INSERT OR IGNORE` statements when inserting.
   If an insert fails because of a constraint violation, then the system will attempt to recover using 1 of 2 different
   approaches:
   
   1. If the object implements the `SyncableModel` protocol, the system will check the existing database row and
   if the row has no local changes (syncStatus == syncInFlightStatus == .synced) then it will update the existing row
   with non-key data from the new object. If there are local changes then no update will be performed.
   This option has a slight performance hit but is safe for cases where the local database might contain changes that only
   exist in the local database and should not be overwritten by data being loaded from other sources (i.e., a network response).
   
   2. If the object is not a `SyncableModel`, then the system will attempt to update the existing row using secondary keys if they
   exist and falling back to the primary key.  If the update fails, then an error is returned.
   
   If this is true, then the system will use `INSERT OR REPLACE` statements which will blindly replace any existing rows in
   the database that trigger a constraint violation.  This is the fastest option and is suitable if the database won't ever contain
   data locally that is newer than data you will load from other sources (i.e., a network response).
   */
  public static var blindlyReplaceDuplicates = false
  private static var dbs: Array<DBMeta> = []
  private static var isRetry: Bool = false

  private static var currentQueue: FMDatabaseQueue? {
    get {
      return dbs.last?.queue
    }
  }
  
  public class func push(_ dbPath: String?, dbDef: DBDef.Type) throws {
    try push(dbPath, dbDefs: [dbDef])
  }
  
  public class func push(_ dbPath: String?, dbDefs: [DBDef.Type]) throws {
    guard dbs.count > 0 else {
      throw DBError.pushFailed
    }
    
    try open(dbPath, dbDefs: dbDefs)
  }
  
  public class func pop(deleteDB: Bool) throws {
    guard dbs.count > 1 else {
      Log.error("Can't pop a database if there isn't more than one db open.")
      throw DBError.popFailed
    }
    
    close(deleteDB: deleteDB)
  }
  
  @discardableResult
  public class func open(_ dbPath: String?, dbDef: DBDef.Type, pushOnStack: Bool = true) throws -> DBMeta? {
    try open(dbPath, dbDefs: [dbDef], pushOnStack: pushOnStack)
  }
    
  @discardableResult
  public class func open(_ dbPath: String?, dbDefs: [DBDef.Type], pushOnStack: Bool = true) throws -> DBMeta? {
    Log.info("Open database queue at: \(dbPath ?? "IN_MEMORY_DB")")
    
    try validateNamespaces(dbDefs: dbDefs)

    guard let queue = FMDatabaseQueue(path: dbPath) else {
      throw DBError.dbPathInvalid
    }

    var upgradeFailed = false
    var emptyNamespaceStartVersion: Int? = nil
    
    //Update sModel scheme
    queue.inDatabase { (db) -> Void in
      var startSchemaVersion = Int(db.userVersion)
      
      //Need to adjust old use of `userVersion` to track single DBDef file to new use of tracking the internal sModel schema only
      if startSchemaVersion > 0 && startSchemaVersion < 1_000 {
        Log.info("Migrating `userVersion` to track sModel internal schema. Capturing version of un-namespaced tables at version: \(startSchemaVersion)")
        emptyNamespaceStartVersion = startSchemaVersion
        startSchemaVersion = 0
        
      } else if startSchemaVersion != 0 { //Already migrated to internal sModel schema so adjust startSchemaVersion
        startSchemaVersion -= 1_000
        
      } else {
        Log.debug("Newly created db")
      }
      
      let endSchemaVersion = sModelDefs.defs.count
      
      if let unProcessedDefs = Utils.selectNewDefs(currentVersion: startSchemaVersion, defs: sModelDefs.defs) {
        let defRange = "\(startSchemaVersion + 1)-\(endSchemaVersion)"
        Log.info("\nExecuting SQL Statements (\(defRange))\n\(unProcessedDefs)")
        
        db.beginTransaction()
        if db.executeStatements(unProcessedDefs) {
          db.commit()
          db.userVersion = UInt32(endSchemaVersion + 1_000)

          Log.info("Successfully updated sModel db schema to version v\(endSchemaVersion)")

        } else {
          upgradeFailed = true
          Log.error("DBUpgradeFailed currentVersion=\(startSchemaVersion) to newVersion=\(endSchemaVersion)")
          return
        }
      
      } else { //already current
        Log.info("sModel db schema is current at version v\(startSchemaVersion)")
      }
    }

    guard !upgradeFailed else {
      Log.error("Unable to setup/upgrade the sModel db schema tables that are required for sModel to run correctly.")
      fatalError()
    }
    
    var dbMeta: DBMeta? = DBMeta(queue: queue, path: dbPath)
    if let dbMeta = dbMeta, pushOnStack {
      dbs.append(dbMeta)
    }

    //Load the details about each dbdef that has been previously loaded
    var defTrackers = !pushOnStack ? Dictionary<String, DBDefTracker>() : DBDefTracker.allInstances().reduce(Dictionary<String, DBDefTracker>()) { (accumulator, tracker) -> Dictionary<String, DBDefTracker> in
      accumulator.merging([tracker.namespace: tracker]) { (tracker1, tracker2) -> DBDefTracker in
        preconditionFailure("Namespace collision: \(tracker1) conflicts with \(tracker2)")
      }
    }
    
    //Run the sql scripts for each dbDef that hasn't been run yet
    for dbDef in dbDefs {
      let tracker = defTrackers[dbDef.namespace] ?? DBDefTracker(namespace: dbDef.namespace)
      defTrackers[dbDef.namespace] = tracker
      
      try tracker.validate(dbDef: dbDef)
      
      queue.inDatabase({ (db) -> Void in
        var startSchemaVersion = tracker.version
        if let emptyNamespaceStartVersion = emptyNamespaceStartVersion, dbDef.namespace.isEmpty {
          startSchemaVersion = emptyNamespaceStartVersion
          tracker.version = startSchemaVersion
          tracker.lastUpdated = Date()
        }
        let endSchemaVersion = dbDef.defs.count
        
        if let unProcessedDefs = Utils.selectNewDefs(currentVersion: startSchemaVersion, defs: dbDef.defs) {
          let defRange = "\(startSchemaVersion + 1)-\(endSchemaVersion)"
          Log.info("\n\(dbDef.namespace):: Executing SQL Statements (\(defRange))\n\(unProcessedDefs)")
          
          db.beginTransaction()
          if db.executeStatements(unProcessedDefs) {
            db.commit()
            
            tracker.version = endSchemaVersion
            tracker.updateLastHash(dbDef: dbDef)
            tracker.lastUpdated = Date()

            Log.info("\(dbDef.namespace):: Successfully updated db schema to version v\(endSchemaVersion)")

          } else {
            upgradeFailed = true
            if isRetry {
              Log.error("\(dbDef.namespace):: DBSetupFailed currentVersion=\(startSchemaVersion) to newVersion=\(endSchemaVersion)")
            } else {
              Log.error("\(dbDef.namespace):: DBUpgradeFailed currentVersion=\(startSchemaVersion) to newVersion=\(endSchemaVersion)")
            }
            return
          }
        
        } else { //already current
          Log.info("\(dbDef.namespace):: Database is current at version v\(startSchemaVersion)")
        }
      })
      guard !upgradeFailed else { break }
    }
    
    if upgradeFailed {
      if pushOnStack {
        dbs.removeLast()
      }
      
      if isRetry { //retry failed so don't retry again
        throw DBError.restoreFailed

      } else {
        Log.error("Error upgrading db to latest version.  Removing database and reinitializing.")
        self.close()

        if let dbPath = dbPath {
          do {
            try FileManager.default.removeItem(atPath: dbPath)
          } catch {
            Log.error("Error trying to remove main db: \(dbPath)")
          }
        }
        isRetry = true
        do {
          dbMeta = try self.open(dbPath, dbDefs: dbDefs, pushOnStack: pushOnStack)
        } catch {
          Log.error("Error trying to recreate db: \(String(describing: dbPath))")
          throw DBError.recreateFailed
        }
        return dbMeta
      }
      
    } else if pushOnStack {
      let trackerSaves = defTrackers.values.compactMap { try? $0.createSaveStatement() }
      guard trackerSaves.count == defTrackers.values.count else {
        Log.error("Error creating save statements for all DBDefTracker objects.")
        fatalError()
      }
      
      do {
        try DBManager.executeStatements(trackerSaves) { (_, _) in }
      } catch {
        Log.error("Error saving db schema versions: \(error)")
      }
    }

    return dbMeta
  }

  public class func clone(destinationPath: String, callback:(Bool)->()) {
    guard let dbMeta = dbs.last else {
      Log.error("There is no database currently open.")
      callback(false)
      return
    }
    
    guard let dbPath = dbMeta.path else {
      Log.error("Current database is an in-memory db and cannot be cloned.")
      callback(false)
      return
    }
    dbMeta.queue.inExclusiveTransaction { (db, rollback) in //need to lock the database from any writes while we copy it
      do {
        try FileManager.default.copyItem(atPath: dbPath, toPath: destinationPath)
        callback(true)
      } catch {
        Log.error("Unable to clone database: \(error)")
        callback(false)
      }
    }
  }
  
  public class func close() {
    while dbs.count > 0 {
      close(deleteDB: dbs.count > 1)
    }
  }

  private class func close(deleteDB: Bool = false) {
    if let dbMeta = dbs.popLast() {
      dbMeta.queue.close()
      if let path = dbMeta.path, deleteDB {
        do {
          try FileManager.default.removeItem(atPath: path)
        } catch {
          Log.warn("Can't delete db file (\(path)): \(error)")
        }
      }
    }
  }
  
  private class func validateNamespaces(dbDefs: [DBDef.Type]) throws {
    var namespaces = Set<String>()
    for def in dbDefs {
      guard !namespaces.contains(def.namespace) else {
        let msg = dbDefs.map({"\($0)>>\($0.namespace)"}).joined(separator: "\n")
        Log.error("DBDef namespace conflict: \n\(msg)")
        throw DBError.namespaceConflict
      }
      namespaces.insert(def.namespace)
    }
  }

  public class func getDBPath(_ fileName: String) -> String? {
    if let documentsPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first {
      let dbPath = documentsPath.appending("/\(fileName).sqlite3")
      return dbPath
    }
    return nil
  }

  public class func getDBQueue() throws -> FMDatabaseQueue {
    guard let queue = currentQueue else {
      Log.error("DB Queue was not initialized so we can't return it")
      throw DBError.missingDBQueue
    }
    return queue
  }

  /**
   Delete all the rows in all the tables.  If there are tables you want to be left alone, include the
   table names in the `excludes` array.
   
   @param excludes Array of table names to not truncate.
   */
  public class func truncateAllTables(excludes: Array<String> = []) {
    guard let queue = try? getDBQueue() else { return }

    queue.inDatabase { (db) in
      guard let result = db.getSchema() else {
        Log.error("Error getting db schema")
        return
      }
      while result.next() {
        if let type = result.string(forColumn: "type") , type == "table" {
          if
            let tableName = result.string(forColumn: "name"),
            !tableName.hasPrefix(sModelDefs.namespace),
            !excludes.contains(tableName)
          {
            do {
              try db.executeUpdate("DELETE FROM \(tableName)", values: nil)
              Log.debug("Truncated data from the '\(tableName)' table.")
            } catch {
              Log.error("Error truncating data in the '\(tableName)' table.")
            }
          }
        }
      }
    }
  }

  public class func executeUpdateQuery(_ query: String, params: Any...) {
    do {
      try executeStatement(StatementParts(sql: query, values: params, type: .update), resultHandler: {_ in })
    } catch {
      Log.warn("Failed to update db (query): \(error)")
    }
  }

  public class func resultDictionariesFromQuery(_ query: String, params: Any...) -> Array<NSDictionary> {
    var resultDicts = [NSDictionary]()
    do {
      try executeStatement(StatementParts(sql: query, values: params, type: .query), resultHandler: { (result) in
        while (result?.next())! {
          if let resultDict = result?.resultDictionary {
            resultDicts.append(resultDict as NSDictionary)
          }
        }
      })
    } catch {
      Log.warn("Failed to query db (query): \(error)")
    }
    return resultDicts
  }

  public class func executeStatement(_ statement: StatementParts, resultHandler: @escaping (FMResultSet?) -> ()) throws -> Void {
    try executeStatements([statement]) { (results, _) in
      if let result = results.first {
        resultHandler(result)
      } else {
        resultHandler(nil)
      }
    }
  }

  /**
   Executes an array of statements in order as part of a single transaction.  An array of result objects is generated from each statement and passed to the `resultsHandler`.
   
   @param statements The statements to be executed.
   
   @param silentInserts Defaults to `false`.  By default, when an insert statement fails because of a constraint violation, this function will instead execute an update on
   that conflicting row in the database and perform a select on that object to get the latest data from the db.  Setting this parameter to `true` will skip the step of querying
   the object from the db.
   
   @return An `Array<FMResultSet?>` objects.  One for each statement that was run if there is a result for that statement.
   */
  public class func executeStatements(_ statements: Array<StatementParts>, silentInserts: Bool = false, resultsHandler: @escaping (Array<FMResultSet?>, Array<ResultState>) -> ()) throws -> Void {
    let queue = try getDBQueue()
    var transactionError: Error?

    queue.inTransaction { (db, rollback) in
      var results = [FMResultSet?]()
      var resultStates = [ResultState]()
      do {
        for statement in statements {
          switch statement.type {
          case .insert:
            try db.executeUpdate(statement.sql, values: statement.values)
            results.append(nil)
            resultStates.append(.success)
            
          case .query:
            let result = try db.executeQuery(statement.sql, values: statement.values)
            results.append(result)
            resultStates.append(.success)
            
          case .update:
            try db.executeUpdate(statement.sql, values: statement.values)
            results.append(nil)
            resultStates.append(.success)
          
          //Handle non-syncable statements
          case let .save(syncable, updateByPrimaryKey, selectByPrimaryKey, updateBySecondaryKey, selectBySecondaryKey, _, _) where !syncable:
            try db.executeUpdate(statement.sql, values: statement.values) //attempt an Insert into the database first
            if db.changes > 0 { //successful insert
              results.append(nil)
              resultStates.append(.success)
              
            } else { //insert failed so attempt an update
              var update = updateByPrimaryKey // default to primary key
              var select = selectByPrimaryKey
              var usingSecondary = false
              var resultState = ResultState.duplicateExists
              //Favor an update on a secondary key if those values exist. Common case is we are trying to save an object from a
              //network response that already is in the db but we didn't want to check for it's existence before the save.
              if
                let secondaryUpdate = updateBySecondaryKey,
                let secondarySelect = selectBySecondaryKey
              {
                update = secondaryUpdate
                select = secondarySelect
                usingSecondary = true
              }
              
              try db.executeUpdate(update.sql, values: update.values)
              if db.changes == 0 && usingSecondary { //update on the secondary key failed so try on the primary key
                try db.executeUpdate(updateByPrimaryKey.sql, values: updateByPrimaryKey.values)
                select = selectByPrimaryKey
                
                if db.changes == 0 {
                  throw QueryError.insertUpdateFailed
                } else { //if you are updating using the primary key then there is no duplicate, it's just the same object.
                  resultState = .success
                }
              }
              
              if !silentInserts { //read the entry from the database so we have the latest values for this row
                let result = try db.executeQuery(select.sql, values: select.values)
                results.append(result)
              } else {
                results.append(nil)
              }
              resultStates.append(resultState)
            }
          
          //Handle syncable statements
          case let .save(syncable, updateByPrimaryKey, selectByPrimaryKey, _, selectBySecondaryKey, updateSyncableBySecondaryKey, selectSyncableBySecondaryKey) where syncable:
            //syncable objects should perform update, if row already exists in db and isn't waiting for sync
            let result = try db.executeQuery(selectByPrimaryKey.sql, values: selectByPrimaryKey.values)
            if result.next() {
              //Row with this primary key already exists so perform update and return
              //Allow this regardless of the sync flag states. If we don't, then there is no way to update the sync flag state values when they aren't all `synced`.
              do {
                try db.executeUpdate(updateByPrimaryKey.sql, values: updateByPrimaryKey.values)
                results.append(nil)
                resultStates.append(.success)
                result.close()
                
              } catch {
                guard (db.lastError() as NSError).code == 19 else {//rethrow error if it wasn't a constraint violation (19)
                  throw error
                }
                //Constraint violation on secondary key so statement is attempting to turn an existing row into a row that is a duplicate of another existing row
                //Fetch the existing row and return it as the result
                if let select = selectBySecondaryKey {
                  let localResult = try db.executeQuery(select.sql, values: select.values)
                  results.append(localResult)
                  resultStates.append(.wouldCreateDuplicate)
                }
                result.close()
              }
              continue
            }
            result.close()
            
            //allow update based on secondaryKey if the existing row doesn't have any local changes to sync
            if
              let update = updateSyncableBySecondaryKey,
              let select = selectSyncableBySecondaryKey
            {
              let localIsSyncedResult = try db.executeQuery(select.sql, values: select.values)
              if localIsSyncedResult.next() { //object with this secondary key already exists and is in a synced state so perform update and return
                localIsSyncedResult.close()
                try db.executeUpdate(update.sql, values: update.values)

                //read the existing row that was updated so we can return it
                let localResult = try db.executeQuery(select.sql, values: select.values)
                results.append(localResult)
                resultStates.append(.duplicateExists)
                continue
              }
              localIsSyncedResult.close()
            }

            //The object doesn't exist in the db in a synced state, attempt an Insert into the database
            try db.executeUpdate(statement.sql, values: statement.values)
            if db.changes > 0 { //successful insert
              results.append(nil)
              resultStates.append(.success)
              
            } else { //insert failed so object must be unsynced so read existing unsynced row.
              let select = selectBySecondaryKey ?? selectByPrimaryKey
              if !silentInserts { //read the entry from the database so we have the latest values for this row
                let result = try db.executeQuery(select.sql, values: select.values)
                results.append(result)
              } else {
                results.append(nil)
              }
              resultStates.append(.duplicateExists)
            }
            
          case .save: preconditionFailure("Previous two cases should handle all .save possibilities but the compiler doesn't recognize it.")
          }
        }
        resultsHandler(results, resultStates)

        for result in results {
          result?.close()
        }

      } catch {
        Log.warn("Failed to query/update db: \(error)")
        rollback.initialize(to: true)
        transactionError = QueryError.failed(errorCode: Int(db.lastErrorCode()))
      }
    }

    if let transactionError = transactionError {
      throw transactionError
    }
  }
}
