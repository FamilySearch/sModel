//
//  BatchTests.swift
//  sModel
//
//  Created by Stephen Lynn on 1/6/17.
//  Copyright © 2017 FamilySearch. All rights reserved.
//

import XCTest
@testable import sModel

class BatchTests: XCTestCase {
  override func setUp() {
    super.setUp()
    try! DBManager.open(nil, dbDef: DBTestDefs.self)
  }
  
  override func tearDown() {
    DBManager.close()
    super.tearDown()
  }
  
  //MARK: Happy path
  
  func testBatchSave_withDuplicateEntries() {
    var t1 = Tree(name: "tree1")
    t1.serverId = "t1"
    let t2 = Tree(name: "tree2")
    var t1Dup = Tree(name: "tree1Dup")
    t1Dup.serverId = "t1"
    let t3 = Tree(name: "tree3")
    
    do {
      let t1Statement = try t1.createSaveStatement()
      let t2Statement = try t2.createSaveStatement()
      let t1DupStatement = try t1Dup.createSaveStatement()
      let t3Statement = try t3.createSaveStatement()
      
      try DBManager.executeStatements([t1Statement, t2Statement, t1DupStatement, t3Statement], resultsHandler: { (results, _) in })
      
      guard
        let t3FromDB = t3.readFromDB(),
        let t1FromDB = t1.readFromDB()
      else {
        XCTFail()
        return
      }
      XCTAssertEqual(t1FromDB.name, "tree1Dup")
      XCTAssertNil(t1Dup.readFromDB(), "Should drop duplicate entry when using batch saves")
      XCTAssertEqual(t3FromDB.name, "tree3")
      
    } catch {
      XCTFail()
    }
  }
  
  func testBatchInserts_withReplace() {
    DBManager.blindlyReplaceDuplicates = true
    
    let statementsA = generateInsertStatements(count: 10, prefix: "A")
    let statementsB = generateInsertStatements(count: 10, prefix: "B")
    
    try! DBManager.executeStatements(statementsA) { (results, _) in
      XCTAssertEqual(10, results.count)
    }
    
    try! DBManager.executeStatements(statementsB) { (results, _) in
      XCTAssertEqual(10, results.count)
    }
    
    guard let thing1 = Thing.firstInstanceWhere("tid = ?", params: "tid1") else {
      XCTFail("Thing with tid = 'tid1' should exist")
      return
    }
    
    XCTAssertEqual("B thing 1", thing1.name)
    
    DBManager.blindlyReplaceDuplicates = false
  }
  
  func testBatchInserts() {
    DBManager.blindlyReplaceDuplicates = false
    
    let statementsA = generateInsertStatements(count: 10, prefix: "A")
    let statementsB = generateInsertStatements(count: 10, prefix: "B")
    
    try! DBManager.executeStatements(statementsA) { (results, _) in
      XCTAssertEqual(10, results.count)
    }
    
    try! DBManager.executeStatements(statementsB) { (results, _) in
      XCTAssertEqual(10, results.count)
    }
    
    guard let thing1 = Thing.firstInstanceWhere("tid = ?", params: "tid1") else {
      XCTFail("Thing with tid = 'tid1' should exist")
      return
    }
    
    XCTAssertEqual("B thing 1", thing1.name)
  }
  
  func testBatchFailedTransaction() {
    let sourceStatements = generateInsertStatements(count: 10, prefix: "A")
    
    try! DBManager.executeStatements(sourceStatements) { (results, _) in
      XCTAssertEqual(10, results.count)
    }
    XCTAssertEqual(Thing.numberOfInstancesWhere(nil), 10)
    
    var statements = Array<StatementParts>()
    statements.append(Thing.createDeleteAllStatement())
    statements.append(StatementParts(sql: "SELECT FROM WHERE INVALID SQL STATEMENT", values: [], type: .query))
    
    do {
      try DBManager.executeStatements(statements, resultsHandler: { (results, _) in
        XCTFail("Should not have made it in here")
      })
    } catch {
      XCTAssertEqual(error.localizedDescription, "The operation couldn’t be completed. (sModel.QueryError error 0.)")
    }
    
    XCTAssertEqual(Thing.numberOfInstancesWhere(nil), 10, "Failed transaction should have been rolled back")
  }
  
  func testBatchInsert_Performance_blindlyReplace() {
    DBManager.blindlyReplaceDuplicates = true
    let count = 10000
    
    let statementsA = generateInsertStatements(count: count, prefix: "A")
    let statementsB = generateInsertStatements(count: count, prefix: "B")
    
    self.measure {
      try! DBManager.executeStatements(statementsA, silentInserts: true) { (results, _) in
        XCTAssertEqual(count, results.count)
      }
      try! DBManager.executeStatements(statementsB, silentInserts: true) { (results, _) in
        XCTAssertEqual(count, results.count)
      }
      DBManager.truncateAllTables()
    }
    DBManager.blindlyReplaceDuplicates = false
  }
  
  func testBatchInsert_Performance() {
    DBManager.blindlyReplaceDuplicates = false
    let count = 10000
    
    let statementsA = generateInsertStatements(count: count, prefix: "A")
    let statementsB = generateInsertStatements(count: count, prefix: "B")
    
    self.measure {
      try! DBManager.executeStatements(statementsA, silentInserts: true) { (results, _) in
        XCTAssertEqual(count, results.count)
      }
      try! DBManager.executeStatements(statementsB, silentInserts: true) { (results, _) in
        XCTAssertEqual(count, results.count)
      }
      DBManager.truncateAllTables()
    }
  }
  
  func testBatchSyncableInsert_Performance() {
    DBManager.blindlyReplaceDuplicates = false
    let count = 10000
    
    let statementsA = generateSyncableInsertStatements(count: count, prefix: "A")
    let statementsB = generateSyncableInsertStatements(count: count, prefix: "B")
    
    self.measure {
      try! DBManager.executeStatements(statementsA, silentInserts: true) { (results, _) in
        XCTAssertEqual(count, results.count)
      }
      try! DBManager.executeStatements(statementsB, silentInserts: true) { (results, _) in
        XCTAssertEqual(count, results.count)
      }
      DBManager.truncateAllTables()
    }
  }
  
  private func generateInsertStatements(count: Int, prefix: String) -> Array<StatementParts> {
    var statements = [StatementParts]()
    
    for i in 0..<count {
      let thing = Thing(tid: "tid\(i)", name: "\(prefix) thing \(i)", place: nil, other: 0, otherDouble: 0)
      
      if let statement = try? thing.createSaveStatement() {
        statements.append(statement)
      }
    }
    
    return statements
  }
  
  private func generateSyncableInsertStatements(count: Int, prefix: String) -> Array<StatementParts> {
    var statements = [StatementParts]()
    
    for i in 0..<count {
      let sThing = SyncableThing(tid: "tid\(i)", name: "\(prefix) animal \(i)", place: nil)

      if let statement = try? sThing.createSaveStatement() {
        statements.append(statement)
      }
    }
    
    return statements
  }
}
