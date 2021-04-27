//
//  exampleModel.swift
//  sModelTests
//
//  Created by Stephen Lynn on 2/22/19.
//  Copyright © 2019 FamilySearch. All rights reserved.
//

import Foundation
import sModel

public struct Pet: ModelDef {
  public var id: String
  public var name: String
  
  public init(id: String, name: String) {
    self.id = id
    self.name = name
  }
  
  public typealias ModelType = Pet
  public static let tableName = PetModuleDBDefs.namespaced(name: "Pet")
  public var primaryKeys: Array<CodingKey> { return [CodingKeys.id] }
  public var secondaryKeys: Array<CodingKey> { return [] }
}
