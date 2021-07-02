import XCTest
@testable import sModel

class SchemaTests: XCTestCase {
  override func setUp() {
    super.setUp()
    ChangeableDBDefs.reset()
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

      XCTAssertEqual(db.userVersion, 1_002)
    }
  }
  
  func testSchemaMigration_2_to_3() {
    //In the move from how we tracked schema version in v2 of sModel to how we track it in v3, we repurposed the db.userVersion value.
    //The db.userVersion will now be used to track which version of sModel's internal schema is installed and the schema versions
    //for different DBDef files will be tracked in the `DBDefTracker` table. This test make sure that we are migrating our use of
    //db.userVersion correctly.
    guard let path = DBManager.getDBPath("testName") else {
      XCTFail("getDBPath should have returned a path")
      return
    }
    
    try? FileManager.default.removeItem(at: URL(fileURLWithPath: path))
    
    //setup a database in the old style
    struct OldDefs: DBDef {
      static let namespace = ""
      static let defs: [String] = [
        """
        CREATE TABLE "Person" (
          "id" TEXT PRIMARY KEY,
          "name" TEXT
        );
        """,
        
        """
        CREATE TABLE "Pet" (
          "id" TEXT PRIMARY KEY,
          "name" TEXT
        );
        """
      ]
    }
    try! DBManager.open(path, dbDef: OldDefs.self)
    
    var queue = try! DBManager.getDBQueue()
    
    Log.debug("Set database back to old style.")
    queue.inDatabase { (db) in
      db.userVersion = 2
      try! db.executeUpdate("DROP TABLE \(DBDefTracker.tableName);", values: nil)
    }

    DBManager.close()
    
    //open database in 3.x method
    try! DBManager.open(path, dbDef: OldDefs.self)
    queue = try! DBManager.getDBQueue()

    queue.inDatabase { (db) in
      XCTAssertTrue(db.tableExists("Person"))
      XCTAssertTrue(db.columnExists("id", inTableWithName: "Person"))

      XCTAssertEqual(db.userVersion, 1_002)
    }
    
    let tracker = DBDefTracker.firstInstanceWhere("namespace = ?", params: OldDefs.namespace)
    XCTAssertEqual(tracker?.version, 2)
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

      XCTAssertEqual(db.userVersion, 1_002)
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
  
  func testInvalidSchemaUpdate_alterPreviouslyUsedDef() {
    let dbName = tempDBName()
    do {
      try DBManager.open(dbName, dbDefs: [ChangeableDBDefs.self])
      DBManager.close()
    } catch DBError.invalidDBDefChange {
      XCTFail("This should have not have thrown the .invalidDBDefChange error")
    } catch {
      XCTFail("This should have not have thrown any errors")
    }
    
    //alter ChangeableDBDefs in an invalid way
    XCTAssertEqual(ChangeableDBDefs.defs.count, 2)
    var defs = ChangeableDBDefs.defs
    defs.removeLast()
    defs.append(ChangeableDBDefs.invalidDBDef2Change)
    ChangeableDBDefs.defs = defs
    XCTAssertEqual(ChangeableDBDefs.defs.count, 2)
    
    do {
      try DBManager.open(dbName, dbDefs: [ChangeableDBDefs.self])
      DBManager.close()
      XCTFail("This should have thrown the .invalidDBDefChange error")
      
    } catch DBError.invalidDBDefChange {
      //this is the error that should have been thrown
    } catch {
      XCTFail()
    }
  }
  
  func testInvalidSchemaUpdate_alterPreviouslyUsedDefWithNewDef() {
    let dbName = tempDBName()
    do {
      try DBManager.open(dbName, dbDefs: [ChangeableDBDefs.self])
      DBManager.close()
    } catch DBError.invalidDBDefChange {
      XCTFail("This should have not have thrown the .invalidDBDefChange error")
    } catch {
      XCTFail("This should have not have thrown any errors")
    }
    
    //alter ChangeableDBDefs in an invalid way
    XCTAssertEqual(ChangeableDBDefs.defs.count, 2)
    var defs = ChangeableDBDefs.defs
    defs.removeLast()
    defs.append(ChangeableDBDefs.invalidDBDef2Change)
    defs.append(ChangeableDBDefs.validDBDef3Addition)
    ChangeableDBDefs.defs = defs
    XCTAssertEqual(ChangeableDBDefs.defs.count, 3)
    
    do {
      try DBManager.open(dbName, dbDefs: [ChangeableDBDefs.self])
      DBManager.close()
      XCTFail("This should have thrown the .invalidDBDefChange error")
      
    } catch DBError.invalidDBDefChange {
      //this is the error that should have been thrown
    } catch {
      XCTFail()
    }
  }
  
  func testValidSchemaUpdate() {
    let dbName = tempDBName()
    do {
      try DBManager.open(dbName, dbDefs: [ChangeableDBDefs.self])
      
      let tracker = DBDefTracker.firstInstanceWhere("namespace = ?", params: ChangeableDBDefs.namespace)
      XCTAssertEqual(tracker?.version, 2)
      
      try? Pet(id: "p1", name: "pet1", active: true).save()
      
      DBManager.close()
    } catch DBError.invalidDBDefChange {
      XCTFail("This should have not have thrown the .invalidDBDefChange error")
    } catch {
      XCTFail("This should not have thrown any errors")
    }
    
    //alter ChangeableDBDefs in an invalid way
    XCTAssertEqual(ChangeableDBDefs.defs.count, 2)
    var defs = ChangeableDBDefs.defs
    defs.append(ChangeableDBDefs.validDBDef3Addition)
    ChangeableDBDefs.defs = defs
    XCTAssertEqual(ChangeableDBDefs.defs.count, 3)
    
    do {
      try DBManager.open(dbName, dbDefs: [ChangeableDBDefs.self])
      
      let tracker = DBDefTracker.firstInstanceWhere("namespace = ?", params: ChangeableDBDefs.namespace)
      XCTAssertEqual(tracker?.version, 3)
      
      let pets = Pet.allInstances()
      XCTAssertEqual(pets.count, 1)
      
      DBManager.close()
      
    } catch DBError.invalidDBDefChange {
      XCTFail("This should have not have thrown the .invalidDBDefChange error")
    } catch {
      XCTFail("This should not have thrown any errors")
    }
  }
  
  func testValidSchemaUpdate_prehash_tohash() {
    let dbName = tempDBName()
    do {
      try DBManager.open(dbName, dbDefs: [ChangeableDBDefs.self])
      
      let tracker = DBDefTracker.firstInstanceWhere("namespace = ?", params: ChangeableDBDefs.namespace)
      XCTAssertEqual(tracker?.version, 2)
      
      //clear hash to simulate pre-hash world
      XCTAssertTrue(tracker?.lastHash.isEmpty == false)
      tracker?.lastHash = ""
      try? tracker?.save()
      
      DBManager.close()
    } catch DBError.invalidDBDefChange {
      XCTFail("This should have not have thrown the .invalidDBDefChange error")
    } catch {
      XCTFail("This should not have thrown any errors")
    }
    
    //alter ChangeableDBDefs in an invalid way
    XCTAssertEqual(ChangeableDBDefs.defs.count, 2)
    var defs = ChangeableDBDefs.defs
    defs.append(ChangeableDBDefs.validDBDef3Addition)
    ChangeableDBDefs.defs = defs
    XCTAssertEqual(ChangeableDBDefs.defs.count, 3)
    
    do {
      try DBManager.open(dbName, dbDefs: [ChangeableDBDefs.self])
      
      let tracker = DBDefTracker.firstInstanceWhere("namespace = ?", params: ChangeableDBDefs.namespace)
      XCTAssertEqual(tracker?.version, 3)
      
      DBManager.close()
      
    } catch DBError.invalidDBDefChange {
      XCTFail("This should have not have thrown the .invalidDBDefChange error")
    } catch {
      XCTFail("This should not have thrown any errors")
    }
  }
  
  private func tempDBName() -> String {
    let directory = NSTemporaryDirectory()
    let filename = "\(UUID().uuidString).sqlite"
    let fileURL = URL(fileURLWithPath: directory).appendingPathComponent(filename)
    return fileURL.absoluteString
  }
}
