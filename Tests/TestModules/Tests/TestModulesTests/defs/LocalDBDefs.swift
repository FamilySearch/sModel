//
//  LocalDBDefs.swift
//  sModelTests
//
//  Created by Stephen Lynn on 5/13/20.
//  Copyright © 2020 FamilySearch. All rights reserved.
//

import Foundation
import sModel

struct LocalDBDefs: DBDef {
  static let namespace = "LocalDBDefs"
  
  static let defs: [String] = [
    //dbDef 1
    """
    CREATE TABLE "\(table: Person.self)" (
      "id" TEXT PRIMARY KEY,
      "name" TEXT,
      "email" TEXT,
      "age" INTEGER
    );
    """,
    
    //dbDef 2
    """
    ALTER TABLE \(namespace)_Person ADD active INTEGER;
    """
  ]
}
