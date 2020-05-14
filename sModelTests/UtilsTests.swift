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
  func testSelectDefs() throws {
    let defs = ["a","b","c","d","e","f"]
    XCTAssertEqual(Utils.selectDefs(currentVersion: 0, defs: defs), "a\n\nb\n\nc\n\nd\n\ne\n\nf")
    XCTAssertEqual(Utils.selectDefs(currentVersion: 1, defs: defs), "b\n\nc\n\nd\n\ne\n\nf")
    XCTAssertEqual(Utils.selectDefs(currentVersion: 2, defs: defs), "c\n\nd\n\ne\n\nf")
    XCTAssertEqual(Utils.selectDefs(currentVersion: 3, defs: defs), "d\n\ne\n\nf")
    XCTAssertEqual(Utils.selectDefs(currentVersion: 4, defs: defs), "e\n\nf")
    XCTAssertEqual(Utils.selectDefs(currentVersion: 5, defs: defs), "f")
    XCTAssertNil(Utils.selectDefs(currentVersion: 6, defs: defs))
  }
}
