//
//  ExampleDBDefs.swift
//  sModelTests
//
//  Created by Stephen Lynn on 5/13/20.
//  Copyright © 2020 FamilySearch. All rights reserved.
//

import Foundation
import sModel

struct ExampleDBDefs: DBDef {
  static let namespace = ""
  static let defs: [String] = [
    //dbDef 1
    """
    CREATE TABLE "\(Person.tableName)" (
      "id" TEXT PRIMARY KEY,
      "name" TEXT,
      "email" TEXT,
      "age" INTEGER
    );
    """,
    
    //dbDef 2
    """
    ALTER TABLE \(Person.tableName) ADD active INTEGER;

    CREATE TABLE "\(Message.tableName)" (
      "localId" TEXT PRIMARY KEY,
      "messageId" TEXT,
      "content" TEXT,
      "createdOn" REAL,
      "ownerPersonId" TEXT,
      "syncStatus" INTEGER,
      "syncInFlightStatus" INTEGER
    );
    CREATE UNIQUE INDEX "main"."INDEX_messageId" ON \(Message.tableName) ("messageId");
    """
  ]
}
