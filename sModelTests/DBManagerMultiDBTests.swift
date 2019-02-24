import XCTest
@testable import sModel

class DBManagerMultiDBTests: XCTestCase {

  override func setUp() {
    super.setUp()
    openDB()
  }

  override func tearDown() {
    DBManager.close()
    super.tearDown()
  }

  private func openDB() {
    try! DBManager.open(nil, dbDefFilePaths: TestHelper.getTestSQLPaths())
  }
  
  private func pushDB() {
    try! DBManager.push(nil, dbDefFilePaths: TestHelper.getTestSQLPaths())
  }
  
  func testCascadeClose() {
    pushDB()
    pushDB()
    DBManager.close()
  }
  
  func testPop_onlyRoot() {
    do {
      try DBManager.pop(deleteDB: false)
    } catch {
      return
    }
    XCTFail("Should have thrown an exception")
  }

  func testDatabaseStack() {
    insertThing("tid1", name: "thing 1")
    guard Thing.firstInstanceWhere("tid = ?", params: "tid1") != nil else {
      XCTFail("Thing should have had a value")
      return
    }

    pushDB()

    guard Thing.firstInstanceWhere("tid = ?", params: "tid1") == nil else {
      XCTFail("Thing should not have value in new db")
      return
    }

    insertThing("tid2", name: "thing 2")
    guard Thing.firstInstanceWhere("tid = ?", params: "tid2") != nil else {
      XCTFail("Thing2 should have had a value")
      return
    }

    try! DBManager.pop(deleteDB: false)

    guard Thing.firstInstanceWhere("tid = ?", params: "tid1") != nil else {
      XCTFail("Thing should have had a value")
      return
    }
    guard Thing.firstInstanceWhere("tid = ?", params: "tid2") == nil else {
      XCTFail("Thing2 should not have had a value")
      return
    }
  }

  @discardableResult
  private func insertThing(_ tid: String, name: String) -> Thing {
    let newThing = Thing(tid: tid, name: name, other: 0, otherDouble: 0)
    try? newThing.save()
    return newThing
  }
}
