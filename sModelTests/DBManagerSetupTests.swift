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
    var paths = DBManager.getDBDefFiles(bundle: Bundle(for: type(of: self)))!
    paths.sort()

    let dbMeta = try! DBManager.open(nil, dbDefFilePaths: paths, pushOnStack: false)
    dbMeta?.queue.inDatabase({ (db) in
      let result = db.getSchema()
      XCTAssertTrue(result.next())
    })
    
    do {
      _ = try DBManager.getDBQueue()
      XCTFail("DBManager should not have saved a db queue in it's internal stack")
    } catch DBError.missingDBQueue {
      
    } catch {
      XCTFail("DBManager should have thrown a DBError.missingDBQueue error")
    }
  }

  func testBadDBPath() {
    do {
      try DBManager.open("/badPath/bob.sqlite3", dbDefFilePaths: ["badSqlFilePath"])
      XCTFail("DBManager should have thrown an error when given a bad path")
    } catch DBError.dbPathInvalid {

    } catch {
      XCTFail("DBManager should have thrown a DBError.dbPathInvalid error but instead threw: \(error)")
    }
  }

  func testFailedDBUpgrade_Creation() {
    let paths = Bundle(for: type(of: self)).paths(forResourcesOfType: "badSql", inDirectory: nil)

    do {
      try DBManager.open(nil, dbDefFilePaths: paths)
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

  func testGetDBDefFiles() {
    guard let paths = DBManager.getDBDefFiles(bundle: Bundle(for: type(of: self))) else {
      XCTFail("Should have found sql files in test bundle")
      return
    }
    XCTAssertEqual(paths.count, 2)
  }

}
