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
  
  func testInstancesWhere_nomatches() {
    insertABunchOfThings(10)
    
    let things = Thing.instancesWhere("tid in (?)", params: "nomatch")
    
    XCTAssertNotNil(things)
    XCTAssertEqual(things.count, 0)
  }
  
  func testInstancesWhere_arrayOfParams() {
    insertABunchOfThings(10)
    
    let things = Thing.instancesWhere("tid = ? AND name = ?", params: ["tid1", "thing 1"])
    
    XCTAssertNotNil(things)
    XCTAssertEqual(things.count, 1)
    XCTAssertEqual(things[0].tid, "tid1")
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

  private func insertABunchOfThings(_ count: Int) {
    for i in 0..<count {
      insertThing("tid\(i)", name: "thing \(i)")
    }
  }

  @discardableResult
  private func insertThing(_ tid: String, name: String) -> Thing {
    let newThing = Thing()
    newThing.tid = tid
    newThing.name = name
    newThing.save()

    return newThing
  }
}
