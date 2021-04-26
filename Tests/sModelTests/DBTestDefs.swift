//
//  DBDefs.swift
//  sModelTests
//
//  Created by Stephen Lynn on 5/13/20.
//  Copyright © 2020 FamilySearch. All rights reserved.
//

import Foundation
import sModel

struct DBTestDefs: DBDef {
  static let namespace = "DBTestDefs"
  static let defs: [String] = [
    //dbDef 1
    """
    CREATE TABLE "Thing" (
      "localId" TEXT PRIMARY KEY,
      "tid" TEXT,
      "name" TEXT,
      "place" TEXT
    );

    CREATE UNIQUE INDEX "main"."INDEX_tid" ON Thing ("tid");

    CREATE TABLE "Animal" (
      "aid" TEXT PRIMARY KEY,
      "name" TEXT,
      "living" INTEGER,
      "lastUpdated" REAL,
      "ids" BLOB,
      "props" BLOB
    );

    CREATE TABLE "Tree" (
      "localId" TEXT PRIMARY KEY,
      "name" TEXT,
      "status" INTEGER,
      "serverId" TEXT
    );
    CREATE UNIQUE INDEX "main"."INDEX_tree_serverId" ON Tree ("serverId");

    CREATE TABLE "SyncableThing" (
      "localId" TEXT PRIMARY KEY,
      "tid" TEXT,
      "name" TEXT,
      "place" TEXT,
      "syncStatus" INTEGER,
      "syncInFlightStatus" INTEGER
    );

    CREATE UNIQUE INDEX "main"."INDEX_syncabletid" ON SyncableThing ("tid");
    """,
    
    //dbDef 2
    """
    CREATE TABLE "Place" (
      "localId" TEXT PRIMARY KEY,
      "placeId" TEXT,
      "name" TEXT,
      "isHot" INTEGER,
      "isWet" INTEGER
    );

    CREATE UNIQUE INDEX "main"."INDEX_placeId" ON Place ("placeId");

    ALTER TABLE Thing ADD other INTEGER;
    ALTER TABLE Thing ADD otherDouble REAL;
    """
  ]
}
