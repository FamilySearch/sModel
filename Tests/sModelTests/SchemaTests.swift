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
    try! DBManager.open(nil, dbDef: DBTestDefs.self)

    let queue = try! DBManager.getDBQueue()

    queue.inDatabase { (db) in
      XCTAssertTrue(db.tableExists("Thing"))
      XCTAssertTrue(db.columnExists("tid", inTableWithName: "Thing"))

      XCTAssertEqual(db.userVersion, 1)
    }
  }
  
  func testMultipleDbDefs() {
    try! DBManager.open(nil, dbDefs: [DBTestDefs.self, ExampleDBDefs.self])

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
      XCTAssertTrue(db.columnExists("placeId", inTableWithName: "Place"))
      XCTAssertTrue(db.columnExists("name", inTableWithName: "Place"))
      
      XCTAssertTrue(db.tableExists("_Person"))
      XCTAssertTrue(db.columnExists("id", inTableWithName: Person.tableName))
      XCTAssertTrue(db.columnExists("name", inTableWithName: Person.tableName))
      XCTAssertTrue(db.columnExists("email", inTableWithName: Person.tableName))
      XCTAssertTrue(db.columnExists("age", inTableWithName: Person.tableName))
      XCTAssertTrue(db.columnExists("active", inTableWithName: Person.tableName))
      
      XCTAssertTrue(db.tableExists("_Message"))
      XCTAssertTrue(db.columnExists("localId", inTableWithName: Message.tableName))
      XCTAssertTrue(db.columnExists("messageId", inTableWithName: Message.tableName))
      XCTAssertTrue(db.columnExists("content", inTableWithName: Message.tableName))
      XCTAssertTrue(db.columnExists("createdOn", inTableWithName: Message.tableName))

      XCTAssertEqual(db.userVersion, 1)
    }
    
    var tracker = DBDefTracker.firstInstanceWhere("namespace = ?", params: DBTestDefs.namespace)
    XCTAssertEqual(tracker?.version, 2)
    
    tracker = DBDefTracker.firstInstanceWhere("namespace = ?", params: ExampleDBDefs.namespace)
    XCTAssertEqual(tracker?.version, 2)
  }
  
  func testDBDef_namespaced() {
    XCTAssertEqual("_table", ExampleDBDefs.namespaced(name: "table"))
    XCTAssertEqual("DBTestDefs_table", DBTestDefs.namespaced(name: "table"))
  }
}
