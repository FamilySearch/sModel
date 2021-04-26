//
//  PetModuleDBDefs.swift
//  sModelTests
//

import Foundation
import sModel

public struct PersonModuleDBDefs: DBDef {
  public static let namespace = "PersonModule"
  public static let defs: [String] = [
    //dbDef 1
    """
    CREATE TABLE "\(Person.tableName)" (
      "id" TEXT PRIMARY KEY,
      "name" TEXT,
      "hairColor" TEXT
    );
    """,
    
    //dbDef 2
    """
    ALTER TABLE \(Person.tableName) ADD eyeColor TEXT;
    """
  ]
}
