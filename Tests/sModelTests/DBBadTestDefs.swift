//
//  DBBadTestDefs.swift
//  sModelTests
//
//  Created by Stephen Lynn on 5/13/20.
//  Copyright © 2020 FamilySearch. All rights reserved.
//

import Foundation
import sModel

struct DBBadTestDefs: DBDef {
  static let namespace = "DBBadTestDefs"
  static let defs: [String] = [
    //dbDef 1
    """
    CREATE TABLE "Thing" (
      "tid" TEXT PRIMARY KEY
    );

    CREATE TABLE "Thing" (
      "tid" TEXT PRIMARY KEY
    );
    """
  ]
}
