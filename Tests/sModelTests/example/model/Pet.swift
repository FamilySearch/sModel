//
//  Pet.swift
//  
//
//  Created by Stephen Lynn on 7/1/21.
//

import Foundation
import sModel

struct Pet: ModelDef {
  var id: String
  var name: String
  var active: Bool
  
  typealias ModelType = Pet
  static let tableName = ChangeableDBDefs.namespaced(name: "Pet")
  var primaryKeys: Array<CodingKey> { return [CodingKeys.id] }
  var secondaryKeys: Array<CodingKey> { return [] }
}
