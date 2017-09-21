//
//  ExperimentTests.swift
//  sModelTests
//
//  Created by Stephen Lynn on 9/20/17.
//  Copyright © 2017 FamilySearch. All rights reserved.
//

import XCTest
@testable import sModel

class ExperimentTests: XCTestCase {
  
  struct Person: SQLCodable {
    var name: String
    var age: Int
    var dict: Dictionary<String,String>
    var arr: Array<String>
    
    var tableName: String { return "Person" }
    var primaryKeys: Array<CodingKey> { return [CodingKeys.name] }
    var secondaryKeys: Array<CodingKey> { return [CodingKeys.name, CodingKeys.age] }
  }
  
  override func setUp() {
    super.setUp()
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  func testEncoding() {
    let p = Person(name: "Stephen", age: 40, dict: ["prop": "value"], arr: ["first", "second"])
    
    do {
      let e = try SQLEncoder.encode(p)
      print("hit")
    } catch {
      print("Error: \(error)")
    }
//    let finalClauses = [
//      SQLPair(clause: "name = ?", value: "Stephen"),
//      SQLPair(clause: "age = ?", value: 40)
//    ]
  }
  
}
