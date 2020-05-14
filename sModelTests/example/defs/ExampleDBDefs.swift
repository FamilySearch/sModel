//
//  ExampleDBDefs.swift
//  sModelTests
//
//  Created by Stephen Lynn on 5/13/20.
//  Copyright © 2020 FamilySearch. All rights reserved.
//

import Foundation

struct ExampleDBDefs {
static let defs: [String] = [
    //dbDef 1
    """
    CREATE TABLE "Person" (
      "id" TEXT PRIMARY KEY,
      "name" TEXT,
      "email" TEXT,
      "age" INTEGER
    );
    """,
    
    //dbDef 2
    """
    ALTER TABLE Person ADD active INTEGER;

    CREATE TABLE "Message" (
      "localId" TEXT PRIMARY KEY,
      "messageId" TEXT,
      "content" TEXT,
      "createdOn" REAL,
      "ownerPersonId" TEXT,
      "syncStatus" INTEGER,
      "syncInFlightStatus" INTEGER
    );
    CREATE UNIQUE INDEX "main"."INDEX_messageId" ON Message ("messageId");
    """
  ]
}
