//
//  CreateStatementTests.swift
//  sModelTests
//
//  Created by Stephen Lynn on 2/22/19.
//  Copyright © 2019 FamilySearch. All rights reserved.
//

import XCTest
@testable import sModel

class CreateStatementTests: XCTestCase {

  override func setUp() {
    super.setUp()
    try! DBManager.open(nil, dbDefs: DBTestDefs.defs)
  }
  
  override func tearDown() {
    DBManager.close()
    super.tearDown()
  }
  //MARK: Statement Options
  
  func testCreateReadFirstInstance() {
    let statement = Thing.createReadFirstInstance(whereClause: "tid = ? AND name = ?", params: "tid1", "thing 1")
    XCTAssertEqual(statement.sql, "SELECT * FROM Thing WHERE tid = ? AND name = ? LIMIT 1")
    XCTAssertEqual(statement.values.count, 2)
  }
  
  func testCreateReadInstancesFullQuery() {
    let statement = Thing.createReadInstances(query: "SELECT * FROM Thing WHERE tid = ? AND name = ?", params: "tid1", "thing 1")
    XCTAssertEqual(statement.sql, "SELECT * FROM Thing WHERE tid = ? AND name = ?")
    XCTAssertEqual(statement.values.count, 2)
  }
  
  func testCreateReadInstancesWhere() {
    let statement = Thing.createReadInstances(whereClause: "tid = ? AND name = ?", params: "tid1", "thing 1")
    XCTAssertEqual(statement.sql, "SELECT * FROM Thing WHERE tid = ? AND name = ?")
    XCTAssertEqual(statement.values.count, 2)
  }
  
  func testCreateReadInstancesWhere_arrayParams() {
    let statement = Thing.createReadInstances(whereClause: "tid = ? AND name = ?", params: ["tid1", "thing 1"])
    XCTAssertEqual(statement.sql, "SELECT * FROM Thing WHERE tid = ? AND name = ?")
    XCTAssertEqual(statement.values.count, 2)
  }
  
  func testCreateReadInstancesOrderedBy() {
    let statement = Thing.createReadInstances(orderedBy: "tid, name")
    XCTAssertEqual(statement.sql, "SELECT * FROM Thing ORDER BY tid, name")
    XCTAssertEqual(statement.values.count, 0)
  }
  
  func testCreateReadAllInstances() {
    let statement = Thing.createReadAllInstances()
    XCTAssertEqual(statement.sql, "SELECT * FROM Thing")
    XCTAssertEqual(statement.values.count, 0)
  }
  
  func testCreateSaveStatement_insert() {
    let thing = Thing(tid: "tid1", name: "thing 1", place: nil, other: 0, otherDouble: 0)
    
    guard let statement = try? thing.createSaveStatement() else {
      XCTFail()
      return
    }
    
    guard case let .save(syncable, updateByPrimaryKey, selectPrimary, updateSecondary, selectSecondary, updateSecondarySyncable, selectSecondarySyncable) = statement.type else {
      XCTFail()
      return
    }
    
    XCTAssertFalse(syncable)
    XCTAssertEqual(statement.sql, "INSERT OR IGNORE INTO Thing (localId,tid,name,other,otherDouble) VALUES (?,?,?,?,?)")
    XCTAssertEqual(5, statement.values.count)
    XCTAssertEqual(updateByPrimaryKey.sql, "UPDATE Thing SET tid = ?,name = ?,place = NULL,other = ?,otherDouble = ? WHERE localId = ?")
    XCTAssertEqual(5, updateByPrimaryKey.values.count)
    XCTAssertEqual(selectPrimary.sql, "SELECT * FROM Thing WHERE localId = ? LIMIT 1")
    XCTAssertEqual(1, selectPrimary.values.count)
    XCTAssertNotNil(updateSecondary)
    XCTAssertEqual(updateSecondary!.sql, "UPDATE Thing SET name = ?,place = NULL,other = ?,otherDouble = ? WHERE tid = ?")
    XCTAssertEqual(4, updateSecondary!.values.count)
    XCTAssertNotNil(selectSecondary)
    XCTAssertEqual(selectSecondary!.sql, "SELECT * FROM Thing WHERE tid = ? LIMIT 1")
    XCTAssertEqual(1, selectSecondary!.values.count)
    XCTAssertNil(updateSecondarySyncable)
    XCTAssertNil(selectSecondarySyncable)
  }
  
  func testCreateSaveStatement_insert_syncable() {
    let thing = SyncableThing(tid: "tid1", name: "thing 1", place: nil)
    
    guard let statement = try? thing.createSaveStatement() else {
      XCTFail()
      return
    }
    
    guard case .save(let syncable, let updatePrimary, let selectPrimary, let updateSecondary, let selectSecondary, let updateSecondarySyncable, let selectSecondarySyncable) = statement.type else {
      XCTFail()
      return
    }
    
    XCTAssertTrue(syncable)
    XCTAssertEqual(statement.sql, "INSERT OR IGNORE INTO SyncableThing (localId,tid,name,syncStatus,syncInFlightStatus) VALUES (?,?,?,?,?)")
    XCTAssertEqual(5, statement.values.count)
    XCTAssertEqual(updatePrimary.sql, "UPDATE SyncableThing SET tid = ?,name = ?,place = NULL,syncStatus = ?,syncInFlightStatus = ? WHERE localId = ?")
    XCTAssertEqual(5, updatePrimary.values.count)
    XCTAssertEqual(selectPrimary.sql, "SELECT * FROM SyncableThing WHERE localId = ? LIMIT 1")
    XCTAssertEqual(1, selectPrimary.values.count)
    XCTAssertNotNil(updateSecondary)
    XCTAssertEqual(updateSecondary!.sql, "UPDATE SyncableThing SET name = ?,place = NULL,syncStatus = ?,syncInFlightStatus = ? WHERE tid = ?")
    XCTAssertEqual(4, updateSecondary!.values.count)
    XCTAssertNotNil(selectSecondary)
    XCTAssertEqual(selectSecondary!.sql, "SELECT * FROM SyncableThing WHERE tid = ? LIMIT 1")
    XCTAssertEqual(1, selectSecondary!.values.count)
    XCTAssertNotNil(updateSecondarySyncable)
    XCTAssertEqual(updateSecondarySyncable!.sql, "UPDATE SyncableThing SET name = ?,place = NULL WHERE tid = ?")
    XCTAssertEqual(2, updateSecondarySyncable!.values.count)
    XCTAssertNotNil(selectSecondarySyncable)
    XCTAssertEqual(selectSecondarySyncable!.sql, "SELECT * FROM SyncableThing WHERE tid = ? AND syncStatus = ? AND syncInFlightStatus = ? LIMIT 1")
    XCTAssertEqual(3, selectSecondarySyncable!.values.count)
  }
  
  func testCreateSaveStatement_insertOptionalSecondaryKey() {
    var tree = Tree(name: "tree 1")
    tree.serverId = "serverId"
    
    guard let statement = try? tree.createSaveStatement() else {
      XCTFail()
      return
    }
    
    guard case .save(let syncable, let updatePrimary, let selectPrimary, let updateSecondary, let selectSecondary, let updateSecondarySyncable, let selectSecondarySyncable) = statement.type else {
      XCTFail()
      return
    }
    
    XCTAssertFalse(syncable)
    XCTAssertEqual(statement.sql, "INSERT OR IGNORE INTO Tree (localId,name,status,serverId) VALUES (?,?,?,?)")
    XCTAssertEqual(4, statement.values.count)
    XCTAssertEqual(updatePrimary.sql, "UPDATE Tree SET name = ?,status = ?,serverId = ? WHERE localId = ?")
    XCTAssertEqual(4, updatePrimary.values.count)
    XCTAssertEqual(selectPrimary.sql, "SELECT * FROM Tree WHERE localId = ? LIMIT 1")
    XCTAssertEqual(1, selectPrimary.values.count)
    XCTAssertNotNil(updateSecondary)
    XCTAssertEqual(updateSecondary!.sql, "UPDATE Tree SET name = ?,status = ? WHERE serverId = ?")
    XCTAssertEqual(3, updateSecondary!.values.count)
    XCTAssertNotNil(selectSecondary)
    XCTAssertEqual(selectSecondary!.sql, "SELECT * FROM Tree WHERE serverId = ? LIMIT 1")
    XCTAssertEqual(1, selectSecondary!.values.count)
    XCTAssertNil(updateSecondarySyncable)
    XCTAssertNil(selectSecondarySyncable)
  }
  
  func testCreateSaveStatement_updateOptionalSecondaryKey() {
    let tree = Tree(name: "tree 1")
    try? tree.save()
    
    guard let treeFromDB = tree.readFromDB() else {
      XCTFail()
      return
    }
    
    var updateTree = treeFromDB
    updateTree.serverId = "serverId"
    
    guard let statement = try? updateTree.createSaveStatement() else {
      XCTFail()
      return
    }
    guard case .save(let syncable, let updatePrimary, let selectPrimary, let updateSecondary, let selectSecondary, let updateSecondarySyncable, let selectSecondarySyncable) = statement.type else {
      XCTFail()
      return
    }
    
    XCTAssertFalse(syncable)
    XCTAssertEqual(statement.sql, "INSERT OR IGNORE INTO Tree (localId,name,status,serverId) VALUES (?,?,?,?)")
    XCTAssertEqual(4, statement.values.count)
    XCTAssertEqual(updatePrimary.sql, "UPDATE Tree SET name = ?,status = ?,serverId = ? WHERE localId = ?")
    XCTAssertEqual(4, updatePrimary.values.count)
    XCTAssertEqual(selectPrimary.sql, "SELECT * FROM Tree WHERE localId = ? LIMIT 1")
    XCTAssertEqual(1, selectPrimary.values.count)
    XCTAssertNotNil(updateSecondary)
    XCTAssertEqual(updateSecondary!.sql, "UPDATE Tree SET name = ?,status = ? WHERE serverId = ?")
    XCTAssertEqual(3, updateSecondary!.values.count)
    XCTAssertNotNil(selectSecondary)
    XCTAssertEqual(selectSecondary!.sql, "SELECT * FROM Tree WHERE serverId = ? LIMIT 1")
    XCTAssertEqual(1, selectSecondary!.values.count)
    XCTAssertNil(updateSecondarySyncable)
    XCTAssertNil(selectSecondarySyncable)
  }
  
  func testCreateSaveStatement_update() {
    TestHelper.insertThing("tid1", name: "thing 1")
    guard let thing = Thing.firstInstanceWhere("tid = ?", params: "tid1") else {
      XCTFail("should be able read object")
      return
    }
    
    guard let statement = try? thing.createSaveStatement() else {
      XCTFail()
      return
    }
    guard case .save(let syncable, let updatePrimary, let selectPrimary, let updateSecondary, let selectSecondary, let updateSecondarySyncable, let selectSecondarySyncable) = statement.type else {
      XCTFail()
      return
    }
    
    XCTAssertFalse(syncable)
    XCTAssertEqual(statement.sql, "INSERT OR IGNORE INTO Thing (localId,tid,name,other,otherDouble) VALUES (?,?,?,?,?)")
    XCTAssertEqual(5, statement.values.count)
    XCTAssertEqual(updatePrimary.sql, "UPDATE Thing SET tid = ?,name = ?,place = NULL,other = ?,otherDouble = ? WHERE localId = ?")
    XCTAssertEqual(5, updatePrimary.values.count)
    XCTAssertEqual(selectPrimary.sql, "SELECT * FROM Thing WHERE localId = ? LIMIT 1")
    XCTAssertEqual(1, selectPrimary.values.count)
    XCTAssertNotNil(updateSecondary)
    XCTAssertEqual(updateSecondary!.sql, "UPDATE Thing SET name = ?,place = NULL,other = ?,otherDouble = ? WHERE tid = ?")
    XCTAssertEqual(4, updateSecondary!.values.count)
    XCTAssertNotNil(selectSecondary)
    XCTAssertEqual(selectSecondary!.sql, "SELECT * FROM Thing WHERE tid = ? LIMIT 1")
    XCTAssertEqual(1, selectSecondary!.values.count)
    XCTAssertNil(updateSecondarySyncable)
    XCTAssertNil(selectSecondarySyncable)
  }
  
  func testCreateSaveStatement_replaceDuplicates() {
    DBManager.blindlyReplaceDuplicates = true
    let thing = Thing(tid: "tid1", name: "thing 1", place: nil, other: 0, otherDouble: 0)
    
    guard let statement = try? thing.createSaveStatement() else {
      XCTFail()
      return
    }
    
    guard case .insert = statement.type else {
      XCTFail()
      return
    }
    XCTAssertEqual(statement.sql, "INSERT OR REPLACE INTO Thing (localId,tid,name,other,otherDouble) VALUES (?,?,?,?,?)")
    DBManager.blindlyReplaceDuplicates = false
  }
  
  func testCreateDeleteStatements() {
    let thing = Thing(tid: "tid1", name: "thing 1", place: nil, other: 0, otherDouble: 0)
    
    var statement = Thing.createDeleteAllStatement()
    XCTAssertEqual(statement.sql, "DELETE FROM Thing")
    XCTAssertEqual(statement.values.count, 0)
    
    statement = Thing.createDeleteWhere("tid = ?", params: "tid1")
    XCTAssertEqual(statement.sql, "DELETE FROM Thing WHERE tid = ?")
    XCTAssertEqual(statement.values.count, 1)
    
    statement = try! thing.createDeleteStatement()
    XCTAssertEqual(statement.sql, "DELETE FROM Thing WHERE localId = ?")
    XCTAssertEqual(statement.values.count, 1)
  }

}
