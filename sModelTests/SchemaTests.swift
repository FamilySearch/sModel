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
    var paths = Bundle(for: type(of: self)).paths(forResourcesOfType: "sql", inDirectory: nil)
    paths.sort()

    try! DBManager.open(nil, dbDefFilePaths: paths)

    let queue = DBManager.getDBQueue()

    queue.inDatabase { (db) in
      guard let db = db else {
        XCTFail("Should have had a db")
        return
      }
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

      XCTAssertEqual(db.userVersion(), 2)
    }
  }

}
