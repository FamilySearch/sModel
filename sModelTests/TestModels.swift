import Foundation
import sModel

class Thing: ModelDef {
  var localId = UUID().uuidString
  var tid: String
  var name: String?
  var other: Int
  var otherDouble: Double
  
  init(tid: String, name: String?, other: Int, otherDouble: Double) {
    self.tid = tid
    self.name = name
    self.other = other
    self.otherDouble = otherDouble
  }
  
  typealias ModelType = Thing
  var existsInDatabase: Bool = false
  static var tableName = "Thing"
  var primaryKeys: Array<CodingKey> { return [CodingKeys.localId] }
  var secondaryKeys: Array<CodingKey> { return [CodingKeys.tid] }
}

class Animal: ModelDef {
  var aid: String
  var name: String?
  var living: Bool
  var lastUpdated: Date
  var ids: [String]
  var props: ResultDictionary = [:]
  private var propsData: Data = Data()
  
  init(aid: String, name: String?, living: Bool, lastUpdated: Date, ids: Array<String>) {
    self.aid = aid
    self.name = name
    self.living = living
    self.lastUpdated = lastUpdated
    self.ids = ids
  }
  
  private enum CodingKeys: String, CodingKey {
    case aid, name, living, lastUpdated, ids
    case propsData = "props"
  }
  
  typealias ModelType = Animal
  var existsInDatabase: Bool = false
  static var tableName = "Animal"
  var primaryKeys: Array<CodingKey> { return [CodingKeys.aid] }
  var secondaryKeys: Array<CodingKey> { return [] }
}
