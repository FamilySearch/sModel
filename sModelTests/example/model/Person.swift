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
  var primaryKeys: Array<CodingKey> { return [CodingKeys.id] }
  var secondaryKeys: Array<CodingKey> { return [] }
}

struct Message: ModelDef, SyncableModel {
  var localId = UUID().uuidString
  var messageId: String?
  var content: String
  var createdOn: Date
  var ownerPersonId: String
  
  var syncStatus: DataStatus = .localOnly
  var syncInFlightStatus: DataStatus = .synced
  
  typealias ModelType = Message
  static let tableName = "Message"
  var primaryKeys: Array<CodingKey> { return [CodingKeys.localId] }
  var secondaryKeys: Array<CodingKey> { return [CodingKeys.messageId] }
}