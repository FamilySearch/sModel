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
    
    var paths = DBManager.getDBDefFiles(bundle: Bundle(for: type(of: self)))!
    paths.sort()
    
    try! DBManager.open(nil, dbDefFilePaths: paths)
  }
  
  override func tearDown() {
    DBManager.close()
    super.tearDown()
  }
  
  //MARK: Happy path
  
  func testBatchInserts() {
    DBManager.shouldReplaceDuplicates = true
    
    let statementsA = generateInsertStatements(count: 10, prefix: "A")
    let statementsB = generateInsertStatements(count: 10, prefix: "B")
    
    try! DBManager.executeStatements(statementsA) { (results) in
      XCTAssertEqual(10, results.count)
    }
    
    try! DBManager.executeStatements(statementsB) { (results) in
      XCTAssertEqual(10, results.count)
    }
    
    guard let thing1 = Thing.firstInstanceWhere("tid = ?", params: "tid1") else {
      XCTFail("Thing with tid = 'tid1' should exist")
      return
    }
    
    XCTAssertEqual("B thing 1", thing1.name)
    
    DBManager.shouldReplaceDuplicates = false
  }
  
  private func generateInsertStatements(count: Int, prefix: String) -> Array<StatementParts> {
    var statements = [StatementParts]()
    
    for i in 0..<count {
      let thing = Thing(tid: "tid\(i)", name: "\(prefix) thing \(i)", other: 0, otherDouble: 0)
      
      if let statement = try? thing.createSaveStatement() {
        statements.append(statement)
      }
    }
    
    return statements
  }
}
