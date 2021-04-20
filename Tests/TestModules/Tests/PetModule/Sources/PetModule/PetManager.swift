//
//  ExampleUsage.swift
//  sModelTests
//
//  Created by Stephen Lynn on 2/22/19.
//  Copyright © 2019 FamilySearch. All rights reserved.
//

import sModel

public class PetManager {
  public func addPet() throws -> Pet {
    let pet = Pet(id: "pet1", name: "Fred")
    try pet.save()
    return pet
  }
}
