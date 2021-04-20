//
//  ExampleUsage.swift
//  sModelTests
//
//  Created by Stephen Lynn on 2/22/19.
//  Copyright © 2019 FamilySearch. All rights reserved.
//

import sModel

public class PersonManager {
  public func addPerson() throws -> Person {
    let person = Person(id: "modulePerson1", name: "Kurt", hairColor: "brown", eyeColor: "green")
    try person.save()
    return person
  }
}
