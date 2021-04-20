//
//  PetModuleDBDefs.swift
//  sModelTests
//

import Foundation

struct PersonModuleDBDefs {
static let defs: [String] = [
    //dbDef 1
    """
    CREATE TABLE "Person" (
      "id" TEXT PRIMARY KEY,
      "name" TEXT,
      "hairColor" TEXT
    );
    """,
    
    //dbDef 2
    """
    ALTER TABLE Person ADD eyeColor TEXT;
    """
  ]
}
