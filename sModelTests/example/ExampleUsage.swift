//
//  ExampleUsage.swift
//  sModelTests
//
//  Created by Stephen Lynn on 2/22/19.
//  Copyright © 2019 FamilySearch. All rights reserved.
//

import XCTest
import sModel

class ExampleUsage: XCTestCase {

  override func setUp() {
    super.setUp()
    
    guard let paths = DBManager.getDBDefFiles(bundle: Bundle(for: type(of: self))) else {
      XCTFail()
      return
    }
    
    try! DBManager.open(nil, dbDefFilePaths: paths)
  }
  
  override func tearDown() {
    DBManager.close()
    super.tearDown()
  }
  
  func testShowExamplesOfHowToUseSModel() {
    //Add People to database
    var person = Person(id: "p1", name: "Abe", email: nil, age: 10, active: true)
    try? person.save()
    
    let person2 = Person(id: "p2", name: "Bob", email: "bob@email.com", age: 20, active: false)
    try? person2.save()
    
    //Read people from database
    XCTAssertEqual(Person.allInstances().count, 2)
    XCTAssertEqual(Person.instancesWhere("id = ?", params: "p2").count, 1)
    
    //Update person in the database
    let fullName = "Abe Lincoln"
    person.name = fullName
    try? person.save()
    XCTAssertEqual(Person.firstInstanceWhere("id = ?", params: person.id)!.name, fullName)
    
    //Delete person from database
    person2.delete()
    XCTAssertEqual(Person.allInstances().count, 1)
  }
  
  func testShowExampleOfHowtoUseSyncableModel() {
    NEED TO ADD EXAMPLE OF HOW THE SYNCABLE MODEL STUFF WORKS AND CONFLICT RESOLUTION OCCURS
    
    NEED TO REFER TO THIS FOLDER FROM THE README AS A FLESHED OUT EXAMPLE OF HOW TO ACTUALLY USE THIS LIBRARY
    
    XCTFail()
  }
}
