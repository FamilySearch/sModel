import XCTest
@testable import sModel

class DBManagerSetupTests: XCTestCase {

  override func setUp() {
    super.setUp()
  }

  override func tearDown() {
    super.tearDown()
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
