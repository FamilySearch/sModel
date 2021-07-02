//
//  UtilsTests.swift
//  sModelTests
//
//  Created by Stephen Lynn on 5/14/20.
//  Copyright © 2020 FamilySearch. All rights reserved.
//

import XCTest
@testable import sModel

class UtilsTests: XCTestCase {
  func testSelectNewDefs() throws {
    let defs = ["a","b","c","d","e","f"]
    XCTAssertEqual(Utils.selectNewDefs(currentVersion: 0, defs: defs), "a\n\nb\n\nc\n\nd\n\ne\n\nf")
    XCTAssertEqual(Utils.selectNewDefs(currentVersion: 1, defs: defs), "b\n\nc\n\nd\n\ne\n\nf")
    XCTAssertEqual(Utils.selectNewDefs(currentVersion: 2, defs: defs), "c\n\nd\n\ne\n\nf")
    XCTAssertEqual(Utils.selectNewDefs(currentVersion: 3, defs: defs), "d\n\ne\n\nf")
    XCTAssertEqual(Utils.selectNewDefs(currentVersion: 4, defs: defs), "e\n\nf")
    XCTAssertEqual(Utils.selectNewDefs(currentVersion: 5, defs: defs), "f")
    XCTAssertNil(Utils.selectNewDefs(currentVersion: 6, defs: defs))
  }
  
  func testSelectProcessedDefs() throws {
    let defs = ["a","b","c","d","e","f"]
    XCTAssertEqual(Utils.selectProcessedDefs(currentVersion: 6, defs: defs), "a\n\nb\n\nc\n\nd\n\ne\n\nf")
    XCTAssertEqual(Utils.selectProcessedDefs(currentVersion: 5, defs: defs), "a\n\nb\n\nc\n\nd\n\ne")
    XCTAssertEqual(Utils.selectProcessedDefs(currentVersion: 4, defs: defs), "a\n\nb\n\nc\n\nd")
    XCTAssertEqual(Utils.selectProcessedDefs(currentVersion: 3, defs: defs), "a\n\nb\n\nc")
    XCTAssertEqual(Utils.selectProcessedDefs(currentVersion: 2, defs: defs), "a\n\nb")
    XCTAssertEqual(Utils.selectProcessedDefs(currentVersion: 1, defs: defs), "a")
    XCTAssertNil(Utils.selectProcessedDefs(currentVersion: 0, defs: defs))
  }
}
