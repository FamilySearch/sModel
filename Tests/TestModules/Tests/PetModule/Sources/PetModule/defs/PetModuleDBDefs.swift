//
//  PetModuleDBDefs.swift
//  sModelTests
//

import Foundation

struct PetModuleDBDefs {
static let defs: [String] = [
    //dbDef 1
    """
    CREATE TABLE "Pet" (
      "id" TEXT PRIMARY KEY,
      "name" TEXT
    );
    """
  ]
}
