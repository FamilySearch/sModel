import XCTest
@testable import sModel

class ModelTests: XCTestCase {
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
  
  func testInsertDuplicateRow() {
    try? Thing(tid: "tid1", name: "thing 1", other: 10, otherDouble: 10.1234).save()
    guard let thing = Thing.firstInstanceWhere("tid = ?", params: ["tid1"]) else {
      XCTFail()
      return
    }
    
    XCTAssertNotNil(thing)
    XCTAssertEqual(thing.other, 10)
    
    let newThing = Thing(tid: "tid1", name: "thing 1", other: 0, otherDouble: 0)
    
    do {
      try newThing.save()
    } catch ModelError<Thing>.duplicate(let existingItem) {
      XCTAssertEqual(existingItem.tid, "tid1")
      XCTAssertEqual(existingItem.other, 0)
      return
    } catch {
      XCTFail()
    }
    
    XCTFail("Test should have gone through the catch")
  }
  
  
  func testInstancesWhere_arrayOfParams() {
    insertABunchOfThings(10)

    let things = Thing.instancesWhere("tid = ? AND name = ?", params: ["tid1", "thing 1"])

    XCTAssertNotNil(things)
    XCTAssertEqual(things.count, 1)
    XCTAssertEqual(things[0].tid, "tid1")
  }

  func testInstancesWhere_nomatches() {
    insertABunchOfThings(10)

    let things = Thing.instancesWhere("tid in (?)", params: "nomatch")

    XCTAssertNotNil(things)
    XCTAssertEqual(things.count, 0)
  }

  func testDoubleProperties() {
    let thing = insertThing("tid1", name: "thing1")
    thing.other = 23
    thing.otherDouble = 0.23
    try? thing.save()

    let thingFromDB = Thing.firstInstanceWhere("tid = ?", params: "tid1")
    XCTAssertNotNil(thingFromDB)
    XCTAssertEqual(thingFromDB?.otherDouble, 0.23)
  }

  func testBoolAndDateProperties() {
    let a = Animal(aid: "aid", name: nil, living: true, lastUpdated: Date(), ids: [], props: ["prop":"value"])
    
    try? a.save()

    var aFromDB = Animal.firstInstanceWhere("aid = ?", params: "aid")
    XCTAssertTrue(aFromDB!.living)

    aFromDB?.living = false
    try? aFromDB?.save()

    aFromDB = Animal.firstInstanceWhere("aid = ?", params: "aid")
    XCTAssertFalse(aFromDB!.living)
  }

  //MARK: Dealing with null properties

  func testNullPropertyOnUpdate() {
    let thing = insertThing("tid1", name: "thing 1")

    thing.name = nil

    try? thing.save()

    let dbThing = Thing.firstInstanceWhere("tid = ?", params: "tid1")
    XCTAssertNil(dbThing!.name)
  }

  func testInsertNullProperty() {
    let newThing = Thing(tid: "tid1", name: nil, other: 0, otherDouble: 0)
    
    try? newThing.save()

    let dbThing = Thing.firstInstanceWhere("tid = ?", params: "tid1")
    XCTAssertNil(dbThing!.name)
  }

  //MARK: Non primitive data types

  func testInsertGetInstanceWithComplexTypes() {
    let lastUpdatedDate = Date(timeIntervalSince1970: 20000000)
    let ids = ["id1", "id2"]
    let props: ResultDictionary = ["prop1": "val1", "prop2": "val2"]
    
    let newAnimal = Animal(aid: "aid1", name: nil, living: true, lastUpdated: lastUpdatedDate, ids: ids, props: props)
    try? newAnimal.save()
    
    guard let dbAnimal = Animal.firstInstanceWhere("aid = ?", params: "aid1") else {
      XCTFail("Can't read object we just inserted")
      return
    }
    
    XCTAssertEqual(dbAnimal.lastUpdated.timeIntervalSince1970, lastUpdatedDate.timeIntervalSince1970)
    XCTAssertEqual(dbAnimal.ids!.first, ids.first)
    let origProp: String = props["prop2"] as! String
    let dbProp: String = dbAnimal.props["prop2"] as! String
    XCTAssertEqual(dbProp, origProp)
  }
  
  func testInsertGetInstanceWithNilArray() {
    let lastUpdatedDate = Date(timeIntervalSince1970: 20000000)
    let props: ResultDictionary = ["prop1": "val1", "prop2": "val2"]
    
    let newAnimal = Animal(aid: "aid1", name: nil, living: true, lastUpdated: lastUpdatedDate, ids: nil, props: props)
    try? newAnimal.save()
    
    guard let dbAnimal = Animal.firstInstanceWhere("aid = ?", params: "aid1") else {
      XCTFail("Can't read object we just inserted")
      return
    }
    
    XCTAssertNil(dbAnimal.ids)
  }

  //MARK: Statement Options
  
  func testCreateSaveStatement_insert() {
    let thing = Thing(tid: "tid1", name: "thing 1", other: 0, otherDouble: 0)
    
    guard let statement = try? thing.createSaveStatement() else {
      XCTFail()
      return
    }
    
    guard case .save(let syncable, let updatePrimary, let selectPrimary, let updateSecondary, let selectSecondary) = statement.type else {
      XCTFail()
      return
    }
    
    XCTAssertFalse(syncable)
    XCTAssertEqual(statement.sql, "INSERT OR IGNORE INTO Thing (localId,tid,name,other,otherDouble) VALUES (?,?,?,?,?)")
    XCTAssertEqual(5, statement.values.count)
    XCTAssertEqual(updatePrimary.sql, "UPDATE Thing SET tid = ?,name = ?,other = ?,otherDouble = ? WHERE localId = ?")
    XCTAssertEqual(5, updatePrimary.values.count)
    XCTAssertEqual(selectPrimary.sql, "SELECT * FROM Thing WHERE localId = ? LIMIT 1")
    XCTAssertEqual(1, selectPrimary.values.count)
    XCTAssertNotNil(updateSecondary)
    XCTAssertEqual(updateSecondary!.sql, "UPDATE Thing SET name = ?,other = ?,otherDouble = ? WHERE tid = ?")
    XCTAssertEqual(4, updateSecondary!.values.count)
    XCTAssertNotNil(selectSecondary)
    XCTAssertEqual(selectSecondary!.sql, "SELECT * FROM Thing WHERE tid = ? LIMIT 1")
    XCTAssertEqual(1, selectSecondary!.values.count)
  }
  
  func testCreateSaveStatement_insert_syncable() {
    let thing = SyncableThing(tid: "tid1", name: "thing 1")

    guard let statement = try? thing.createSaveStatement() else {
      XCTFail()
      return
    }
    
    guard case .save(let syncable, let updatePrimary, let selectPrimary, let updateSecondary, let selectSecondary) = statement.type else {
      XCTFail()
      return
    }

    XCTAssertTrue(syncable)
    XCTAssertEqual(statement.sql, "INSERT OR IGNORE INTO SyncableThing (localId,tid,name) VALUES (?,?,?)")
    XCTAssertEqual(3, statement.values.count)
    XCTAssertEqual(updatePrimary.sql, "UPDATE SyncableThing SET tid = ?,name = ? WHERE localId = ?")
    XCTAssertEqual(3, updatePrimary.values.count)
    XCTAssertEqual(selectPrimary.sql, "SELECT * FROM SyncableThing WHERE localId = ? LIMIT 1")
    XCTAssertEqual(1, selectPrimary.values.count)
    XCTAssertNotNil(updateSecondary)
    XCTAssertEqual(updateSecondary!.sql, "UPDATE SyncableThing SET name = ? WHERE tid = ?")
    XCTAssertEqual(2, updateSecondary!.values.count)
    XCTAssertNotNil(selectSecondary)
    XCTAssertEqual(selectSecondary!.sql, "SELECT * FROM SyncableThing WHERE tid = ? LIMIT 1")
    XCTAssertEqual(1, selectSecondary!.values.count)
  }
  
  func testCreateSaveStatement_insertOptionalSecondaryKey() {
    var tree = Tree(name: "tree 1")
    tree.serverId = "serverId"
    
    guard let statement = try? tree.createSaveStatement() else {
      XCTFail()
      return
    }
    
    guard case .save(let syncable, let updatePrimary, let selectPrimary, let updateSecondary, let selectSecondary) = statement.type else {
      XCTFail()
      return
    }
    
    XCTAssertFalse(syncable)
    XCTAssertEqual(statement.sql, "INSERT OR IGNORE INTO Tree (localId,name,status,serverId) VALUES (?,?,?,?)")
    XCTAssertEqual(4, statement.values.count)
    XCTAssertEqual(updatePrimary.sql, "UPDATE Tree SET name = ?,status = ?,serverId = ? WHERE localId = ?")
    XCTAssertEqual(4, updatePrimary.values.count)
    XCTAssertEqual(selectPrimary.sql, "SELECT * FROM Tree WHERE localId = ? LIMIT 1")
    XCTAssertEqual(1, selectPrimary.values.count)
    XCTAssertNotNil(updateSecondary)
    XCTAssertEqual(updateSecondary!.sql, "UPDATE Tree SET name = ?,status = ? WHERE serverId = ?")
    XCTAssertEqual(3, updateSecondary!.values.count)
    XCTAssertNotNil(selectSecondary)
    XCTAssertEqual(selectSecondary!.sql, "SELECT * FROM Tree WHERE serverId = ? LIMIT 1")
    XCTAssertEqual(1, selectSecondary!.values.count)
  }
  
  func testCreateSaveStatement_updateOptionalSecondaryKey() {
    let tree = Tree(name: "tree 1")
    try? tree.save()
    
    guard let treeFromDB = tree.readFromDB() else {
      XCTFail()
      return
    }
    
    var updateTree = treeFromDB
    updateTree.serverId = "serverId"
    
    guard let statement = try? updateTree.createSaveStatement() else {
      XCTFail()
      return
    }
    guard case .save(let syncable, let updatePrimary, let selectPrimary, let updateSecondary, let selectSecondary) = statement.type else {
      XCTFail()
      return
    }
    
    XCTAssertFalse(syncable)
    XCTAssertEqual(statement.sql, "INSERT OR IGNORE INTO Tree (localId,name,status,serverId) VALUES (?,?,?,?)")
    XCTAssertEqual(4, statement.values.count)
    XCTAssertEqual(updatePrimary.sql, "UPDATE Tree SET name = ?,status = ?,serverId = ? WHERE localId = ?")
    XCTAssertEqual(4, updatePrimary.values.count)
    XCTAssertEqual(selectPrimary.sql, "SELECT * FROM Tree WHERE localId = ? LIMIT 1")
    XCTAssertEqual(1, selectPrimary.values.count)
    XCTAssertNotNil(updateSecondary)
    XCTAssertEqual(updateSecondary!.sql, "UPDATE Tree SET name = ?,status = ? WHERE serverId = ?")
    XCTAssertEqual(3, updateSecondary!.values.count)
    XCTAssertNotNil(selectSecondary)
    XCTAssertEqual(selectSecondary!.sql, "SELECT * FROM Tree WHERE serverId = ? LIMIT 1")
    XCTAssertEqual(1, selectSecondary!.values.count)
  }
  
  func testCreateSaveStatement_update() {
    insertThing("tid1", name: "thing 1")
    guard let thing = Thing.firstInstanceWhere("tid = ?", params: "tid1") else {
      XCTFail("should be able read object")
      return
    }
    
    guard let statement = try? thing.createSaveStatement() else {
      XCTFail()
      return
    }
    guard case .save(let syncable, let updatePrimary, let selectPrimary, let updateSecondary, let selectSecondary) = statement.type else {
      XCTFail()
      return
    }
    
    XCTAssertFalse(syncable)
    XCTAssertEqual(statement.sql, "INSERT OR IGNORE INTO Thing (localId,tid,name,other,otherDouble) VALUES (?,?,?,?,?)")
    XCTAssertEqual(5, statement.values.count)
    XCTAssertEqual(updatePrimary.sql, "UPDATE Thing SET tid = ?,name = ?,other = ?,otherDouble = ? WHERE localId = ?")
    XCTAssertEqual(5, updatePrimary.values.count)
    XCTAssertEqual(selectPrimary.sql, "SELECT * FROM Thing WHERE localId = ? LIMIT 1")
    XCTAssertEqual(1, selectPrimary.values.count)
    XCTAssertNotNil(updateSecondary)
    XCTAssertEqual(updateSecondary!.sql, "UPDATE Thing SET name = ?,other = ?,otherDouble = ? WHERE tid = ?")
    XCTAssertEqual(4, updateSecondary!.values.count)
    XCTAssertNotNil(selectSecondary)
    XCTAssertEqual(selectSecondary!.sql, "SELECT * FROM Thing WHERE tid = ? LIMIT 1")
    XCTAssertEqual(1, selectSecondary!.values.count)
  }

  func testCreateSaveStatement_replaceDuplicates() {
    DBManager.blindlyReplaceDuplicates = true
    let thing = Thing(tid: "tid1", name: "thing 1", other: 0, otherDouble: 0)
    
    guard let statement = try? thing.createSaveStatement() else {
      XCTFail()
      return
    }

    guard case .insert = statement.type else {
      XCTFail()
      return
    }
    XCTAssertEqual(statement.sql, "INSERT OR REPLACE INTO Thing (localId,tid,name,other,otherDouble) VALUES (?,?,?,?,?)")
    DBManager.blindlyReplaceDuplicates = false
  }

  //MARK: Edge cases
  
  func testInsertDuplicateObject_overwriteExistingDBRowWithLatest() {
    let originalThing = insertThing("tid1", name: "thing 1")
    
    var newThing = Thing(tid: "tid1", name: "otherThing1", other: 0, otherDouble: 0)
    
    XCTAssertNotEqual(originalThing.localId, newThing.localId)
    
    do {
      try newThing.save()
    } catch ModelError<Thing>.duplicate(let existingItem) {
      newThing = existingItem
    } catch {
      XCTFail()
    }
    
    XCTAssertEqual(originalThing.localId, newThing.localId)
    XCTAssertEqual(newThing.name, "otherThing1")
    XCTAssertEqual(newThing.localId, originalThing.localId)
    
    let thingCount = Thing.numberOfInstancesWhere("tid = ?", params: "tid1")
    XCTAssertEqual(thingCount, 1)
  }
  
  func testInsertDuplicateSyncableObject_doNotOverwriteExistingDBRowWithLatest() {
    let originalThing = SyncableThing(tid: "tid1", name: "thing 1")
    try? originalThing.save()
    
    var newThing = SyncableThing(tid: "tid1", name: "otherthing 1")
    
    XCTAssertNotEqual(originalThing.name, newThing.name)
    
    do {
      try newThing.save()
    } catch ModelError<SyncableThing>.duplicate(let existingItem) {
      newThing = existingItem
    } catch {
      XCTFail()
    }
    
    XCTAssertEqual(originalThing.tid, newThing.tid)
    XCTAssertEqual(originalThing.name, newThing.name)
    XCTAssertEqual(newThing.name, "thing 1")
    
    let thingCount = SyncableThing.numberOfInstancesWhere("tid = ?", params: "tid1")
    XCTAssertEqual(thingCount, 1)
  }
  
  func testInsertSyncableWithNullSecondaryKey() {
    let thing = SyncableThing(tid: nil, name: "thing1")
    try? thing.save()
    
    let thingFromDB = thing.readFromDB()
    
    XCTAssertEqual(thingFromDB!.name, "thing1")
  }

  func testGetNonExistentInstance_returnNil() {
    let nonExistentThing = Thing.firstInstanceWhere("tid = ?", params: "blah")

    XCTAssertNil(nonExistentThing)
  }

  func testGetEmptyList_returnEmptyArray() {
    let emptyList = Thing.allInstances()

    XCTAssertNotNil(emptyList)
    XCTAssertEqual(emptyList.count, 0)
  }
  
  func testReadFromDB_unsavedInstance() {
    let thing = Thing(tid: "tidx", name: "thing x", other: 0, otherDouble: 0)
    let otherThing = thing.readFromDB()
    XCTAssertNil(otherThing)
  }

  func testReloadInstance() {
    let thing = insertThing("tid1", name: "thing 1")

    guard let dbThing = thing.readFromDB() else {
      XCTFail("Can't read object we just inserted")
      return
    }
    
    XCTAssertEqual(thing.localId, dbThing.localId)
  }
  
  func testInsertAndUpdateNewObject() {
    var tree = Tree(name: "tree")
    try? tree.save()
    
    XCTAssertNil(tree.serverId)
    
    tree.serverId = "serverId"
    try? tree.save()
    
    XCTAssertEqual("serverId", tree.serverId!)
    
    let treeFromDB = tree.readFromDB()!
    XCTAssertEqual("serverId", treeFromDB.serverId)
  }

  //MARK: Peformance Tests

  func testPerformanceLotsOfInserts() {
    self.measure {
      self.insertABunchOfThings(1_000)
      Thing.deleteAllInstances()
    }
  }

  func testPerformanceLotsOfInsertsReads() {
    self.measure {
      for i in 0..<250 {
        self.insertThing("tid\(i)", name: "thing \(i)")
        _ = Thing.allInstances()
      }
      Thing.deleteAllInstances()
    }
  }

  //MARK: Helpers

  private func insertABunchOfThings(_ count: Int) {
    for i in 0..<count {
      insertThing("tid\(i)", name: "thing \(i)")
    }
  }
  
  @discardableResult
  private func insertThing(_ tid: String, name: String) -> Thing {
    let newThing = Thing(tid: tid, name: name, other: 0, otherDouble: 0)
    try? newThing.save()
    return newThing
  }
}
