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
  static var tableName = "Thing"
  var existsInDatabase: Bool = false
  var primaryKeys: Array<CodingKey> { return [CodingKeys.localId] }
  var secondaryKeys: Array<CodingKey> { return [CodingKeys.tid] }
}

class Animal: ModelDef {
  var aid: String
  var name: String?
  var living: Bool
  var lastUpdated: Date
  var ids: SQLArrayOfStrings
  //TODO test optional array
  //TODO test optional dictionary
  private var propsData: Data = Data()
  var props: ResultDictionary {
    get {
      return (try? Animal.dataToDictionary(propsData)) ?? [:]
    }
    set {
      guard let data = try? Animal.dictionaryToData(newValue) else {
        print("Can't convert dictionary to data: \(newValue)")
        self.propsData = Data()
        return
      }
      self.propsData = data
    }
  }
  
  init(aid: String, name: String?, living: Bool, lastUpdated: Date, ids: Array<String>, props: Dictionary<String,Any>) {
    self.aid = aid
    self.name = name
    self.living = living
    self.lastUpdated = lastUpdated
    self.ids = ids
    self.props = props
  }
  
  private enum CodingKeys: String, CodingKey {
    case aid, name, living, lastUpdated, ids
    case propsData = "props"
  }
  
  typealias ModelType = Animal
  static var tableName = "Animal"
  var existsInDatabase: Bool = false
  var primaryKeys: Array<CodingKey> { return [CodingKeys.aid] }
  var secondaryKeys: Array<CodingKey> { return [] }
}
