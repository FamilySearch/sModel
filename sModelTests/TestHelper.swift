//
//  TestHelper.swift
//  sModelTests
//
//  Created by Stephen Lynn on 2/22/19.
//  Copyright © 2019 FamilySearch. All rights reserved.
//

import Foundation
@testable import sModel

class TestHelper {
  //MARK: Helpers
  
  class func insertABunchOfThings(_ count: Int) {
    for i in 0..<count {
      insertThing("tid\(i)", name: "thing \(i)")
    }
  }
  
  @discardableResult
  class func insertThing(_ tid: String, name: String, place: String? = nil) -> Thing {
    let newThing = Thing(tid: tid, name: name, place: nil, other: 0, otherDouble: 0)
    try? newThing.save()
    return newThing
  }
}
