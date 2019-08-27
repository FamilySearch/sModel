import XCTest
@testable import sModel

class SchemaTests: XCTestCase {
  override func setUp() {
    super.setUp()
  }

  override func tearDown() {
    DBManager.close()
    super.tearDown()
  }

  func testSchemaCreation() {
    let paths = TestHelper.getTestSQLPaths()
    try! DBManager.open(nil, dbDefFilePaths: paths)

    let queue = try! DBManager.getDBQueue()

    queue.inDatabase { (db) in
      XCTAssertTrue(db.tableExists("Thing"))
      XCTAssertTrue(db.columnExists("tid", inTableWithName: "Thing"))
      XCTAssertTrue(db.columnExists("name", inTableWithName: "Thing"))
      XCTAssertTrue(db.columnExists("other", inTableWithName: "Thing"))

      XCTAssertTrue(db.tableExists("Animal"))
      XCTAssertTrue(db.columnExists("aid", inTableWithName: "Animal"))
      XCTAssertTrue(db.columnExists("name", inTableWithName: "Animal"))

      XCTAssertTrue(db.tableExists("Place"))
      XCTAssertTrue(db.columnExists("pid", inTableWithName: "Place"))
      XCTAssertTrue(db.columnExists("name", inTableWithName: "Place"))

      XCTAssertEqual(db.userVersion, 2)
    }
  }

}
