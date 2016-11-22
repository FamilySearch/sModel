import XCTest
@testable import sModel

class ModelTests: XCTestCase {
  override func setUp() {
    super.setUp()

    var paths = Bundle(for: type(of: self)).paths(forResourcesOfType: "sql", inDirectory: nil)
    paths.sort()

    try! DBManager.open(nil, dbDefFilePaths: paths)
  }

  override func tearDown() {
    DBManager.close()
    super.tearDown()
  }

  //MARK: Happy path

  func testGenerateUUID() {
    let uuid = Thing.generateUUID()
    XCTAssertTrue(!uuid.isEmpty)
  }

  func testInsertAndFirstInstance() {
    let newThing = insertThing("tid1", name: "thing 1")
    XCTAssertEqual(newThing.existsInDatabase, true)

    let thingFromDB = Thing.firstInstanceWhere("tid = ?", params: "tid1")
    XCTAssertNotNil(thingFromDB)
    XCTAssertEqual(thingFromDB?.tid, "tid1")
    XCTAssertEqual(thingFromDB?.name, "thing 1")
  }

  func testInsertAndInstancesWhere() {
    insertABunchOfThings(10)

    let thingsFromDB = Thing.instancesWhere("tid = ?", params: "tid3")
    XCTAssertNotNil(thingsFromDB)
    let thing = thingsFromDB[0]
    XCTAssertEqual(thing.tid, "tid3")
    XCTAssertEqual(thing.name, "thing 3")
  }

  func testUpdateInstance() {
    let newThing = insertThing("tid1", name: "thing 1")

    newThing.name = "otherThing 1"
    newThing.save()

    XCTAssertEqual(newThing.name, "otherThing 1")

    let thingFromDB = Thing.firstInstanceWhere("tid = ?", params: "tid1")
    XCTAssertEqual(thingFromDB?.name, "otherThing 1")
  }

  func testReload() {
    let newThing = insertThing("tid1", name: "thing 1")
    newThing.name = "changedName"

    newThing.reload()

    XCTAssertEqual(newThing.name, "thing 1")
  }

  func testInstancesWhere() {
    insertABunchOfThings(10)

    let things = Thing.instancesWhere("tid in (?, ?)", params: "tid1", "tid2")

    XCTAssertEqual(things.count, 2)
    XCTAssertEqual(things[0].name, "thing 1")
    XCTAssertEqual(things[1].name, "thing 2")
  }

  func testInstances() {
    insertABunchOfThings(10)

    let things = Thing.instances("Select * FROM Thing WHERE tid IN (?, ?)", params: "tid1", "tid2")

    XCTAssertEqual(things.count, 2)
    XCTAssertEqual(things[0].name, "thing 1")
    XCTAssertEqual(things[1].name, "thing 2")
  }

  func testInstancesWhere_nomatches() {
    insertABunchOfThings(10)

    let things = Thing.instancesWhere("tid in (?)", params: "nomatch")

    XCTAssertNotNil(things)
    XCTAssertEqual(things.count, 0)
  }

  func testInstancesOrderedBy() {
    insertABunchOfThings(10)

    let things = Thing.instancesOrderedBy("tid ASC")

    XCTAssertEqual(things.count, 10)
    XCTAssertEqual(things[0].name, "thing 0")

    let moreThings = Thing.instancesOrderedBy("tid DESC")

    XCTAssertEqual(moreThings.count, 10)
    XCTAssertEqual(moreThings[0].name, "thing 9")
  }

  func testAllInstances() {
    insertABunchOfThings(10)

    let things = Thing.allInstances()

    XCTAssertEqual(things.count, 10)
    XCTAssertEqual(things[0].name, "thing 0")
  }

  func testDeleteInstance() {
    let newThing = insertThing("tid1", name: "thing 1")
    XCTAssertFalse(newThing.isDeleted)
    XCTAssertFalse(newThing.calledDidDelete)

    let thingFromDB = Thing.firstInstanceWhere("tid = ?", params: "tid1")
    XCTAssertNotNil(thingFromDB)

    newThing.delete()

    XCTAssertTrue(newThing.isDeleted)
    XCTAssertTrue(newThing.calledDidDelete)

    let thingAgainFromDB = Thing.firstInstanceWhere("tid = ?", params: "tid1")
    XCTAssertNil(thingAgainFromDB)
  }

  func testDeleteAllInstances() {
    insertABunchOfThings(10)

    let things = Thing.allInstances()
    XCTAssertEqual(things.count, 10)

    Thing.deleteAllInstances()

    let leftThings = Thing.allInstances()
    XCTAssertEqual(leftThings.count, 0)
  }

  func testDeleteWhere() {
    insertABunchOfThings(10)

    let things = Thing.allInstances()
    XCTAssertEqual(things.count, 10)

    Thing.deleteWhere("tid = ?", params: "tid1")

    let leftThings = Thing.allInstances()
    XCTAssertEqual(leftThings.count, 9)
  }

  func testNumberOfInstancesWhere() {
    insertABunchOfThings(10)

    let count = Thing.numberOfInstancesWhere("tid = ?", params: "tid1")
    XCTAssertEqual(count, 1)
  }


  func testNumberOfInstancesWhere_noWhereClause() {
    insertABunchOfThings(10)

    let count = Thing.numberOfInstancesWhere(nil)
    XCTAssertEqual(count, 10)
  }

  func testBoolProperty() {
    let a = Animal()
    a.aid = "aid"
    a.living = true
    a.save()

    var aFromDB = Animal.firstInstanceWhere("aid = ?", params: "aid")
    XCTAssertTrue(aFromDB!.living)

    a.living = false
    a.save()

    aFromDB = Animal.firstInstanceWhere("aid = ?", params: "aid")
    XCTAssertFalse(aFromDB!.living)
  }

  func testGenericQuery() {
    insertABunchOfThings(10)

    DBManager.executeUpdateQuery("DELETE FROM THING")

    let leftThings = Thing.allInstances()
    XCTAssertEqual(leftThings.count, 0)
  }

  func testDoubleProperties() {
    let thing = insertThing("tid1", name: "thing1")
    thing.other = 23
    thing.otherDouble = 0.23
    thing.save()

    let thingFromDB = Thing.firstInstanceWhere("tid = ?", params: "tid1")
    XCTAssertNotNil(thingFromDB)
    XCTAssertEqual(thingFromDB?.otherDouble, 0.23)
  }

  //MARK: Dealing with null properties

  func testNullPropertyOnUpdate() {
    let thing = insertThing("tid1", name: "thing 1")

    thing.name = nil

    thing.save()

    let dbThing = Thing.firstInstanceWhere("tid = ?", params: "tid1")
    XCTAssertNil(dbThing!.name)
  }

  func testInsertNullProperty() {
    let newThing = Thing()
    newThing.tid = "tid1"
    newThing.name = nil

    XCTAssertFalse(newThing.existsInDatabase)

    newThing.save()

    XCTAssertTrue(newThing.existsInDatabase)
  }

  //MARK: Non primitive data types

  func testInsertGetInstanceWithComplexTypes() {
    let lastUpdatedDate = Date(timeIntervalSince1970: 20000000)
    let ids = ["id1", "id2"]
    let props: ResultDictionary = ["prop1": "val1", "prop2": "val2"]

    let newAnimal = Animal()
    newAnimal.aid = "aid1"
    newAnimal.lastUpdated = lastUpdatedDate
    newAnimal.ids = ids
    newAnimal.props = props

    newAnimal.save()

    let dbAnimal = Animal.firstInstanceWhere("aid = ?", params: "aid1")
    XCTAssertEqual(dbAnimal?.lastUpdated.timeIntervalSince1970, lastUpdatedDate.timeIntervalSince1970)
    XCTAssertEqual(dbAnimal?.ids.first, ids.first)
    let origProp: String = props["prop2"] as! String
    let dbProp: String = dbAnimal!.props["prop2"] as! String
    XCTAssertEqual(dbProp, origProp)
  }

  //MARK: Edge cases

  func testInsertDuplicateObject_overwriteWithLatestFromDB() {
    insertThing("tid1", name: "thing 1")

    let newThing = Thing()
    newThing.tid = "tid1"
    newThing.name = "otherThing 1"
    newThing.save()

    let thingCount = Thing.numberOfInstancesWhere("tid = ?", params: "tid1")

    XCTAssertEqual(newThing.name, "thing 1")
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

  func testReloadDeletedInstance() {
    insertThing("tid1", name: "thing 1")

    guard let thing = Thing.firstInstanceWhere("tid = ?", params: "tid1") else {
      XCTAssert(false, "Couldn't read object we just inserted")
      return
    }

    XCTAssertFalse(thing.isDeleted)

    Thing.deleteWhere("tid = ?", params: "tid1")

    thing.reload()
    XCTAssertTrue(thing.isDeleted)
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

  func insertABunchOfThings(_ count: Int) {
    for i in 0..<count {
      insertThing("tid\(i)", name: "thing \(i)")
    }
  }

  @discardableResult
  func insertThing(_ tid: String, name: String) -> Thing {
    let newThing = Thing()
    newThing.tid = tid
    newThing.name = name
    newThing.save()

    return newThing
  }
}
