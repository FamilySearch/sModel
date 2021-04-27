//
//  exampleModel.swift
//  sModelTests
//
//  Created by Stephen Lynn on 2/22/19.
//  Copyright © 2019 FamilySearch. All rights reserved.
//

import Foundation
import sModel

public struct Person: ModelDef {
  public var id: String
  public var name: String
  public var hairColor: String
  public var eyeColor: String

  public init(id: String, name: String, hairColor: String, eyeColor: String) {
    self.id = id
    self.name = name
    self.hairColor = hairColor
    self.eyeColor = eyeColor
  }
  
  public typealias ModelType = Person
  public static let tableName = PersonModuleDBDefs.namespaced(name: "Person")
  public var primaryKeys: Array<CodingKey> { return [CodingKeys.id] }
  public var secondaryKeys: Array<CodingKey> { return [] }
}
