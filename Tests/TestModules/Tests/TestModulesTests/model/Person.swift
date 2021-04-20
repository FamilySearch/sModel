//
//  exampleModel.swift
//  sModelTests
//
//  Created by Stephen Lynn on 2/22/19.
//  Copyright © 2019 FamilySearch. All rights reserved.
//

import Foundation
import sModel

struct Person: ModelDef {
  var id: String
  var name: String
  var email: String?
  var age: Int
  var active: Bool
  
  typealias ModelType = Person
  static let tableName = "Person"
  static let namespace = "Local"
  var primaryKeys: Array<CodingKey> { return [CodingKeys.id] }
  var secondaryKeys: Array<CodingKey> { return [] }
}
