//
//  SyncableModelTests.swift
//  sModelTests
//
//  Created by Stephen Lynn on 2/22/19.
//  Copyright © 2019 FamilySearch. All rights reserved.
//

import XCTest
@testable import sModel

class SyncableModelTests: XCTestCase {
  override func setUp() {
    super.setUp()
    try! DBManager.open(nil, dbDef: DBTestDefs.self)
  }
  
  override func tearDown() {
    DBManager.close()
    super.tearDown()
  }
  
  func testInsertDuplicateSyncableObject_doNotOverwriteExistingDBRowWithLatest() {
    let originalThing = SyncableThing(tid: "tid1", name: "thing 1", place: nil)
    try? originalThing.save()
    
    var newThing = SyncableThing(tid: "tid1", name: "otherthing 1", place: nil)
    
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
    let thing = SyncableThing(tid: nil, name: "thing1", place: nil)
    try? thing.save()
    
    let thingFromDB = thing.readFromDB()
    
    XCTAssertEqual(thingFromDB!.name, "thing1")
  }
  
  func testUpdateSecondaryKeyAfterInsertOfDuplicate() {
    let origThing = SyncableThing(tid: nil, name: "thing1", place: nil)
    do {
      try origThing.save()
      
      let serverThing = SyncableThing(tid: "tid1", name: "thing1Server", place: nil)
      try serverThing.save()
    } catch {
      XCTFail()
    }
    
    origThing.tid = "tid1" //add secondary key value to object in db that will conflict with another object in db.
    do {
      try origThing.save()
    } catch ModelError<SyncableThing>.wouldCreateDuplicate(let existingItem) {
      XCTAssertEqual(existingItem.tid, "tid1")
      XCTAssertEqual(existingItem.name, "thing1Server")
    } catch {
      XCTFail()
    }
  }
  
  func testSaveExistingSyncableShouldReturnExistingInstance() {
    let thing = SyncableThing(tid: "tid1", name: "thing 1", place: "place 1")
    thing.syncStatus = .synced
    thing.syncInFlightStatus = .synced
    try? thing.save()
    
    let newThing = SyncableThing(tid: "tid1", name: "thing 1 new", place: nil)
    newThing.syncStatus = .synced
    newThing.syncInFlightStatus = .synced
    do {
      try newThing.save()
      XCTFail()
    } catch ModelError<SyncableThing>.duplicate(let existingItem) {
      XCTAssertEqual(thing.localId, existingItem.localId)
      XCTAssertEqual(newThing.name, existingItem.name)
      XCTAssertNil(existingItem.place)
    } catch {
      XCTFail()
    }
  }
  
  func testNonSyncable_lastSaveWins_butPreserveOriginalPrimaryKeyValue() {
    let thing = Thing(tid: "tid1", name: "thing 1", place: nil, other: 0, otherDouble: 0)
    try? thing.save()
    
    let newThing = Thing(tid: "tid1", name: "newThing 1", place: nil, other: 0, otherDouble: 0)
    
    do {
      try newThing.save()
    } catch ModelError<Thing>.duplicate(let existingItem) {
      XCTAssertEqual(existingItem.localId, thing.localId)
      XCTAssertEqual(existingItem.name, newThing.name)
    } catch {
      XCTFail()
    }
    
    let thingFromDB = Thing.firstInstanceWhere("tid = ?", params: "tid1")
    XCTAssertEqual(thingFromDB!.name, "newThing 1")
    XCTAssertEqual(thingFromDB!.localId, thing.localId)
  }
  
  func testSyncable_firstSaveWins_PreserveUpdatesToFirstWhenNotSynced() {
    let thing = SyncableThing(tid: "tid1", name: "thing 1", place: nil)
    thing.syncStatus = .dirty
    try? thing.save()
    
    let newThing = SyncableThing(tid: "tid1", name: "newThing 1", place: nil)
    
    //can't save newThing because thing has non-synced status
    do {
      try newThing.save()
    } catch ModelError<SyncableThing>.duplicate(let existingItem) {
      XCTAssertEqual(existingItem.localId, thing.localId)
      XCTAssertEqual(existingItem.name, thing.name)
    } catch {
      XCTFail()
    }
    
    var thingFromDB = SyncableThing.firstInstanceWhere("tid = ?", params: "tid1")
    XCTAssertEqual(thingFromDB!.name, "thing 1")
    XCTAssertEqual(thingFromDB!.localId, thing.localId)
    
    //still allow updates to original object
    thing.name = "thing1 - updated"
    try? thing.save()
    
    thingFromDB = SyncableThing.firstInstanceWhere("tid = ?", params: "tid1")
    XCTAssertEqual(thingFromDB!.name, "thing1 - updated")
    
    //allow updates from objects read from db
    thingFromDB!.name = "thing1 - copy updated"
    try? thingFromDB!.save()
    
    thingFromDB = SyncableThing.firstInstanceWhere("tid = ?", params: "tid1")
    XCTAssertEqual(thingFromDB!.name, "thing1 - copy updated")
    
    //allow updates from server if there are no local changes
    thing.syncStatus = .synced
    try? thing.save()
    let thingFromServer = SyncableThing(tid: "tid1", name: "serverThing", place: nil)
    do {
      try thingFromServer.save()
    } catch ModelError<SyncableThing>.duplicate(let existingItem) {
      XCTAssertEqual(thing.localId, existingItem.localId)
      XCTAssertEqual(thingFromServer.name, existingItem.name)
    } catch {
      XCTFail()
    }
    
    thingFromDB = SyncableThing.firstInstanceWhere("tid = ?", params: "tid1")
    XCTAssertEqual(thingFromDB!.name, "serverThing")
  }
}
