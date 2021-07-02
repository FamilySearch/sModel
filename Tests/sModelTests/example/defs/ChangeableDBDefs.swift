//
//  ChangeableDBDefs.swift
//  
//
//  Created by Stephen Lynn on 7/1/21.
//

import Foundation
import sModel

struct ChangeableDBDefs: DBDef {
  static let namespace = "Changeable"
  static let originalDefs: [String] = [
    //dbDef 1
    """
    CREATE TABLE "\(Pet.tableName)" (
      "id" TEXT PRIMARY KEY,
      "name" TEXT
    );
    """,
    
    //dbDef 2
    """
    ALTER TABLE \(Pet.tableName) ADD active INTEGER;
    """
  ]
  
  static var defs: [String] = originalDefs
  
  static let invalidDBDef2Change =
    """
    ALTER TABLE \(Pet.tableName) ADD inactive INTEGER;
    """
  
  static let validDBDef3Addition =
    """
    ALTER TABLE \(Pet.tableName) ADD age INTEGER;
    """
  
  static func reset() {
    defs = originalDefs
  }
}
