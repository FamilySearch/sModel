//
//  LifecycleTests.swift
//  sModelTests
//
//  Created by Stephen Lynn on 10/27/17.
//  Copyright © 2017 FamilySearch. All rights reserved.
//

import XCTest
@testable import sModel

class LifecycleTests: XCTestCase {
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
  
  func testUpdateSecondaryKeyAfterInsertOfDuplicate() {
    let origThing = SyncableThing(tid: nil, name: "thing1")
    do {
      try origThing.save()
      
      let serverThing = SyncableThing(tid: "tid1", name: "thing1Server")
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
    let thing = SyncableThing(tid: "tid1", name: "thing 1")
    thing.syncStatus = .synced
    thing.syncInFlightStatus = .synced
    try? thing.save()
    
    let newThing = SyncableThing(tid: "tid1", name: "thing 1 new")
    newThing.syncStatus = .synced
    newThing.syncInFlightStatus = .synced
    do {
      try newThing.save()
    } catch ModelError<SyncableThing>.duplicate(let existingItem) {
      XCTAssertEqual(thing.localId, existingItem.localId)
      XCTAssertEqual(newThing.name, existingItem.name)
    } catch {
      XCTFail()
    }
  }
  
  func testNonSyncable_lastSaveWins_butPreserveOriginalPrimaryKeyValue() {
    let thing = Thing(tid: "tid1", name: "thing 1", other: 0, otherDouble: 0)
    try? thing.save()
    
    let newThing = Thing(tid: "tid1", name: "newThing 1", other: 0, otherDouble: 0)
    
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
    let thing = SyncableThing(tid: "tid1", name: "thing 1")
    thing.syncStatus = .dirty
    try? thing.save()
    
    let newThing = SyncableThing(tid: "tid1", name: "newThing 1")
    
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
    let thingFromServer = SyncableThing(tid: "tid1", name: "serverThing")
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
