import XCTest
@testable import sModel

class DBManagerSetupTests: XCTestCase {

  override func setUp() {
    super.setUp()
  }

  override func tearDown() {
    super.tearDown()
  }
  
  func testDBOpen_notOnStack() {
    let dbMeta = try! DBManager.open(nil, dbDef: DBTestDefs.self, pushOnStack: false)
    
    var enteredQueue = false
    dbMeta?.queue.inDatabase({ (db) in
      let result = db.getSchema()
      XCTAssertTrue(result!.next())
      enteredQueue = true
    })
    XCTAssertTrue(enteredQueue)
    
    do {
      _ = try DBManager.getDBQueue()
      XCTFail("DBManager should not have saved a db queue in it's internal stack")
    } catch DBError.missingDBQueue {
      
    } catch {
      XCTFail("DBManager should have thrown a DBError.missingDBQueue error")
    }
  }
  
  func testDBOpen_passingDef() {
    let dbMeta = try! DBManager.open(nil, dbDefs: [DBTestDefs.self], pushOnStack: false)
    
    var enteredQueue = false
    dbMeta?.queue.inDatabase({ (db) in
      let result = db.getSchema()
      XCTAssertTrue(result!.next())
      enteredQueue = true
    })
    XCTAssertTrue(enteredQueue)
    
    do {
      _ = try DBManager.getDBQueue()
      XCTFail("DBManager should not have saved a db queue in it's internal stack")
    } catch DBError.missingDBQueue {
      
    } catch {
      XCTFail("DBManager should have thrown a DBError.missingDBQueue error")
    }
  }
  
  func testDuplicateNamespaceErrorDetection() {
    struct DBTestDefsClone: DBDef {
      static let namespace = "DBTestDefs"
      static let defs: [String] = []
    }
    
    do {
      try DBManager.open(nil, dbDefs: [DBTestDefs.self, DBTestDefsClone.self])
    } catch {
      
      return
    }
    XCTFail("This should have thrown an exception")
  }
  
  func testBadDBPath() {
    do {
      try DBManager.open("/badPath/bob.sqlite3", dbDef: DBBadTestDefs.self)
      XCTFail("DBManager should have thrown an error when given a bad path")
    } catch DBError.dbPathInvalid {

    } catch {
      XCTFail("DBManager should have thrown a DBError.dbPathInvalid error but instead threw: \(error)")
    }
  }

  func testFailedDBUpgrade_Creation() {
    do {
      try DBManager.open(nil, dbDef: DBBadTestDefs.self)
      XCTFail("DBManager should have thrown an error when given a bad path")
    } catch DBError.recreateFailed {
      print("Threw error when trying to create db with bad schema def.")
    } catch {
      XCTFail("DBManager should have thrown a recreateFailed error but instead threw: \(error)")
    }
  }

  func testGetDBPath() {
    guard let path = DBManager.getDBPath("testName") else {
      XCTFail("getDBPath should have returned a path")
      return
    }
    XCTAssertTrue(path.hasSuffix("Documents/testName.sqlite3"))
  }
  
  func testLargeDBDefArray_Performance() {
    self.measure {
      try! DBManager.open(nil, dbDef: DBLoadTestDefs.self, pushOnStack: false)
    }
  }

}
