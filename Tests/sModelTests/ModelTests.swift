import XCTest
@testable import sModel

class ModelTests: XCTestCase {
  override func setUp() {
    super.setUp()
    try! DBManager.open(nil, dbDefs: DBTestDefs.defs)
  }

  override func tearDown() {
    DBManager.close()
    super.tearDown()
  }

  
  //MARK: Happy path
  
  func testInsertDuplicateRow() {
    try? Thing(tid: "tid1", name: "thing 1", place: nil, other: 10, otherDouble: 10.1234).save()
    guard let thing = Thing.firstInstanceWhere("tid = ?", params: ["tid1"]) else {
      XCTFail()
      return
    }
    
    XCTAssertNotNil(thing)
    XCTAssertEqual(thing.other, 10)
    
    let newThing = Thing(tid: "tid1", name: "thing 1", place: nil, other: 0, otherDouble: 0)
    
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
  
  func testUpdateSecondaryKey() {
    let thing = Thing(tid: "tid1", name: "thing 1", place: nil, other: 0, otherDouble: 0)
    
    do {
      try thing.save()
      
      thing.tid = "tid2" //change a secondary key value
      try thing.save() //should not throw an exception
      
      let t = Thing.firstInstanceWhere("localId = ?", params: thing.localId)
      XCTAssertEqual(t?.tid, "tid2")
      
    } catch {
      XCTFail()
    }
  }
  
  func testInstancesWhere_arrayOfParams() {
    TestHelper.insertABunchOfThings(10)

    let things = Thing.instancesWhere("tid = ? AND name = ?", params: ["tid1", "thing 1"])

    XCTAssertNotNil(things)
    XCTAssertEqual(things.count, 1)
    XCTAssertEqual(things[0].tid, "tid1")
  }

  func testInstancesWhere_nomatches() {
    TestHelper.insertABunchOfThings(10)

    let things = Thing.instancesWhere("tid in (?)", params: "nomatch")

    XCTAssertNotNil(things)
    XCTAssertEqual(things.count, 0)
  }

  func testDoubleProperties() {
    let thing = TestHelper.insertThing("tid1", name: "thing1")
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
    let thing = TestHelper.insertThing("tid1", name: "thing 1")

    thing.name = nil

    try? thing.save()

    let dbThing = Thing.firstInstanceWhere("tid = ?", params: "tid1")
    XCTAssertNil(dbThing!.name)
  }

  func testInsertNullProperty() {
    let newThing = Thing(tid: "tid1", name: nil, place: nil, other: 0, otherDouble: 0)
    
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
  
  func testGenericDataTo_toData() {
    do {
      let names = ["Fido", "Rover", "Mutt"]
      let data = try Animal.toData(names)
      guard let restoredNames: Array<String> = try Animal.dataTo(data) else {
        XCTFail()
        return
      }
      
      XCTAssertEqual(names.count, restoredNames.count)
      XCTAssertEqual(names[0], restoredNames[0])
      XCTAssertEqual(names[1], restoredNames[1])
      XCTAssertEqual(names[2], restoredNames[2])
      
    } catch {
      XCTFail("\(error)")
    }
  }

  //MARK: Edge cases
  
  func testInsertDuplicateObject_overwriteExistingDBRowWithLatest() {
    let originalThing = TestHelper.insertThing("tid1", name: "thing 1", place: "place 1")
    
    var newThing = Thing(tid: "tid1", name: "otherThing1", place: nil, other: 0, otherDouble: 0)
    
    XCTAssertNotEqual(originalThing.localId, newThing.localId)
    
    do {
      try newThing.save()
    } catch ModelError<Thing>.duplicate(let existingItem) {
      newThing = existingItem
    } catch {
      XCTFail()
    }
    
    XCTAssertEqual(originalThing.localId, newThing.localId) //preserve the original localId
    XCTAssertEqual(newThing.name, "otherThing1")
    XCTAssertNil(newThing.place)
    
    let thingCount = Thing.numberOfInstancesWhere("tid = ?", params: "tid1")
    XCTAssertEqual(thingCount, 1)
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
    let thing = Thing(tid: "tidx", name: "thing x", place: nil, other: 0, otherDouble: 0)
    let otherThing = thing.readFromDB()
    XCTAssertNil(otherThing)
  }

  func testReloadInstance() {
    let thing = TestHelper.insertThing("tid1", name: "thing 1")

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
      TestHelper.insertABunchOfThings(1_000)
      Thing.deleteAllInstances()
    }
  }

  func testPerformanceLotsOfInsertsReads() {
    self.measure {
      for i in 0..<250 {
        TestHelper.insertThing("tid\(i)", name: "thing \(i)")
        _ = Thing.allInstances()
      }
      Thing.deleteAllInstances()
    }
  }
}
