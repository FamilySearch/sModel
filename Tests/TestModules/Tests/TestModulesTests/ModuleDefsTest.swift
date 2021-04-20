//
//  ModuleDefsTest.swift
//  TestModulesTests
//
//  Created by Stephen Lynn on 4/20/21.
//  Copyright © 2021 FamilySearch. All rights reserved.
//

import XCTest
import sModel
import PetModule
import PersonModule

class ModuleDefsTest: XCTestCase {

  override func setUp() {
    super.setUp()
    Log.logLevel = .error
    try! DBManager.open(nil, dbDefs: LocalDBDefs.defs)
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
  
  func testUsingModelFromDifferentModule() {
    let pet = Pet(id: "pet1", name: "bob")
    try? pet.save()
    
    guard let readFromDBPet = Pet.firstInstanceWhere("id = ?", params: pet.id) else {
      XCTFail()
      return
    }
    XCTAssertEqual(pet.name, readFromDBPet.name)
  }
  
  func testConflictingPersonFromModule() {
    let modulePerson = PersonModule.Person(id: "mp1", name: "ModuleAbe", hairColor: "brown", eyeColor: "blue")
    try? modulePerson.save()
    
    guard let readFromDBModulePerson = PersonModule.Person.firstInstanceWhere("id = ?", params: modulePerson.id) else {
      XCTFail()
      return
    }
    XCTAssertEqual(modulePerson.name, readFromDBModulePerson.name)
  }
}
