//
//  StickyModelTests.swift
//  sModelTests
//
//  Created by Stephen Lynn on 12/31/19.
//  Copyright © 2019 FamilySearch. All rights reserved.
//

import XCTest
@testable import sModel

class StickyModelTests: XCTestCase {
  override func setUp() {
    super.setUp()
    try! DBManager.open(nil, dbDefFilePaths: TestHelper.getTestSQLPaths())
  }
  
  override func tearDown() {
    DBManager.close()
    super.tearDown()
  }
  
  func testNormalSave() {
    var place = Place(name: "place1")
    place.placeId = "placeId1"
    place.isHot = true
    place.isWet = true
    try? place.save()
    
    guard let checkPlace = Place.firstInstanceWhere("localId = ?", params: place.localId) else {
      XCTFail()
      return
    }
    
    XCTAssertEqual(place.name, checkPlace.name)
    XCTAssertEqual(place.placeId, checkPlace.placeId)
    XCTAssertEqual(place.isHot, checkPlace.isHot)
    XCTAssertEqual(place.isWet, checkPlace.isWet)
  }
  
  func testStickySave_noPreviousStickValue() {
    let placeId = "placeId1"
    
    var place = Place(name: "place1")
    place.placeId = placeId
    try? place.save()
    
    //simulate saving a new version of the same place but with updated attributes
    var placeDup = Place(name: "place1Dup")
    placeDup.placeId = placeId
    placeDup.isHot = true
    placeDup.isWet = true
    try? placeDup.save()
    
    guard let checkPlace = Place.firstInstanceWhere("placeId = ?", params: placeId) else {
      XCTFail()
      return
    }
    
    XCTAssertEqual("place1Dup", checkPlace.name)
    XCTAssertEqual(placeId, checkPlace.placeId)
    XCTAssertTrue(checkPlace.isHot!)
    XCTAssertTrue(checkPlace.isWet!)
  }
  
  func testStickySave_withPreviousStickValueNoNewValue() {
    let placeId = "placeId1"
    
    var place = Place(name: "place1")
    place.placeId = placeId
    place.isHot = true
    place.isWet = true
    try? place.save()
    
    //simulate saving a new version of the same place but with updated attributes
    var placeDup = Place(name: "place1Dup")
    placeDup.placeId = placeId
    try? placeDup.save()
    
    guard let checkPlace = Place.firstInstanceWhere("placeId = ?", params: placeId) else {
      XCTFail()
      return
    }
    
    XCTAssertEqual("place1Dup", checkPlace.name)
    XCTAssertEqual(placeId, checkPlace.placeId)
    XCTAssertTrue(checkPlace.isHot!, "Should retain value from original save even though placeDup had no value")
    XCTAssertNil(checkPlace.isWet)
  }
  
  func testStickySave_overwritePreviousStickyValue() {
    let placeId = "placeId1"
    
    var place = Place(name: "place1")
    place.placeId = placeId
    place.isHot = true
    place.isWet = true
    try? place.save()
    
    //simulate saving a new version of the same place but with updated attributes
    var placeDup = Place(name: "place1Dup")
    placeDup.placeId = placeId
    placeDup.isHot = false
    placeDup.isWet = false
    try? placeDup.save()
    
    guard let checkPlace = Place.firstInstanceWhere("placeId = ?", params: placeId) else {
      XCTFail()
      return
    }
    
    XCTAssertEqual("place1Dup", checkPlace.name)
    XCTAssertEqual(placeId, checkPlace.placeId)
    XCTAssertFalse(checkPlace.isHot!, "Should update to value in placeDup")
    XCTAssertFalse(checkPlace.isWet!)
  }
  
  func testStickySave_stickyValueIsNotNullable() {
    let placeId = "placeId1"
    
    var place = Place(name: "place1")
    place.placeId = placeId
    place.isHot = true
    place.isWet = true
    try? place.save()
    
    place.isHot = nil
    place.isWet = nil
    try? place.save()
    
    guard let checkPlace = Place.firstInstanceWhere("placeId = ?", params: placeId) else {
      XCTFail()
      return
    }
    
    XCTAssertEqual("place1", checkPlace.name)
    XCTAssertEqual(placeId, checkPlace.placeId)
    XCTAssertTrue(checkPlace.isHot!, "Should retain the original value of isHot")
    XCTAssertNil(checkPlace.isWet)
  }
}
