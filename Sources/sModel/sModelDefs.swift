//
//  File.swift
//  
//
//  Created by Stephen Lynn on 4/21/21.
//

import Foundation

struct sModelDefs: DBDef {
  static let namespace = "_sModel"
  static let defs: [String] = [
    """
    CREATE TABLE "\(DBDefTracker.tableName)" (
      "namespace" TEXT PRIMARY KEY,
      "version" INTEGER,
      "lastUpdated" REAL
    );
    """,
    
    """
    ALTER TABLE \(DBDefTracker.tableName) ADD lastHash TEXT;
    """
  ]
}

class DBDefTracker: ModelDef {
  var namespace = ""
  var version = 0
  var lastUpdated = Date()
  var lastHash = ""
  
  typealias ModelType = DBDefTracker
  static var tableName = sModelDefs.namespaced(name: "DBDefTracker")
  var primaryKeys: Array<CodingKey> { [CodingKeys.namespace] }
  var secondaryKeys: Array<CodingKey> { [] }
  
  init(namespace: String) {
    self.namespace = namespace
  }
}

extension DBDefTracker {
  func validate(dbDef: DBDef.Type) throws {
    guard lastHash != "" else { //if we don't have a hash value then always assume dbdefs are valid - deals with old OS versions that don't support hashing
      Log.debug("Hashes are not being used yet so skip validation check.")
      return
    }
    
    guard let processedDefs = Utils.selectProcessedDefs(currentVersion: version, defs: dbDef.defs) else {
      Log.debug("There are no previously processed defs so skip validation check.")
      return
    }
    
    let processedHash = Utils.generateHash(string: processedDefs)
    
    guard processedHash == lastHash else {
      throw DBError.invalidDBDefChange(namespace: namespace)
    }
  }
  
  func updateLastHash(dbDef: DBDef.Type) {
    guard let defString = Utils.selectProcessedDefs(currentVersion: dbDef.defs.count, defs: dbDef.defs) else {
      lastHash = ""
      return
    }
    
    lastHash = Utils.generateHash(string: defString)
  }
}
