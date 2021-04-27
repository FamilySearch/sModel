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
    """
  ]
}

class DBDefTracker: ModelDef {
  var namespace = ""
  var version = 0
  var lastUpdated = Date()
  
  typealias ModelType = DBDefTracker
  static var tableName = sModelDefs.namespaced(name: "DBDefTracker")
  var primaryKeys: Array<CodingKey> { [CodingKeys.namespace] }
  var secondaryKeys: Array<CodingKey> { [] }
  
  init(namespace: String) {
    self.namespace = namespace
  }
}
