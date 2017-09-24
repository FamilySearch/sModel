import Foundation
import sModel

class Thing: ModelDef {
  typealias T = Thing
  var localId: String
  var tid: String
  var name: String?
  var other: Int
  var otherDouble: Double
  
  var existsInDatabase: Bool
  var isDeleted: Bool
  
//  var calledDidDelete = false

  static var tableName = "Thing"
  var primaryKeys: Array<CodingKey> { return [CodingKeys.localId] }
  var secondaryKeys: Array<CodingKey> { return [CodingKeys.tid] }
//
//  func didDelete() {
//    super.didDelete()
//    calledDidDelete = true
//  }
}

class Animal: ModelDef {
  typealias T = Animal
  
  var aid: String
  var name: String?
  var living: Bool
  var lastUpdated: Date
  var ids: [String]
  var props: ResultDictionary
  
  var existsInDatabase: Bool
  var isDeleted: Bool

  var tableName: String { return "Animal" }
  var primaryKeys: Array<CodingKey> { return [CodingKeys.aid] }
  var secondaryKeys: Array<CodingKey> { return [] }
}
