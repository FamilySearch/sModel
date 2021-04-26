//
//  PetModuleDBDefs.swift
//  sModelTests
//

import Foundation
import sModel

public struct PetModuleDBDefs: DBDef {
  public static let namespace = "PetModule"
  public static let defs: [String] = [
    //dbDef 1
    """
    /* Create the table you are migrating from, if it doesn't exist yet, so we don't throw any errors when we try and migrate the data */
    CREATE TABLE IF NOT EXISTS Pet_old_table (
      "id" TEXT,
      "name" TEXT,
      PRIMARY KEY("id")
    );
    /* Create the new table tied to the right namespace */
    CREATE TABLE "\(Pet.tableName)" (
      "id" TEXT PRIMARY KEY,
      "name" TEXT
    );
    INSERT INTO \(Pet.tableName) (id, name)
    SELECT id, name FROM Pet_old_table;
    DROP TABLE Pet_old_table;
    """
  ]
}
