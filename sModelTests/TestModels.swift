import Foundation
import sModel

enum DataStatus: Int, Codable {
  case localOnly = 1, dirty, synced, deleted, temporary, ignore
}

struct Tree: ModelDef {
  var localId = UUID().uuidString
  var name: String
  var status = DataStatus.synced
  var serverId: String?
  
  init(name: String) {
    self.name = name
    self.existsInDatabase = false
  }
  
  typealias ModelType = Tree
  static let tableName = "Tree"
  let existsInDatabase: Bool
  var primaryKeys: Array<CodingKey> { return [CodingKeys.localId] }
  var secondaryKeys: Array<CodingKey> { return [CodingKeys.serverId] }
  static let syncable = false
}

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
    self.existsInDatabase = false
  }
  
  typealias ModelType = Thing
  static let tableName = "Thing"
  let existsInDatabase: Bool
  var primaryKeys: Array<CodingKey> { return [CodingKeys.localId] }
  var secondaryKeys: Array<CodingKey> { return [CodingKeys.tid] }
  static let syncable = false
}

class Animal: ModelDef {
  var aid: String
  var name: String?
  var living: Bool
  var lastUpdated: Date
  var ids: SQLArrayOfStrings?
  private var propsData: Data = Data()
  var props: ResultDictionary {
    get {
      if
        let dictResult = try? Animal.dataToDictionary(propsData),
        let dict = dictResult
      {
        return dict
      }
      return [:]
    }
    set {
      if
        let dataResult = try? Animal.dictionaryToData(newValue),
        let data = dataResult
      {
        propsData = data
        return
      }
      print("Can't convert dictionary to data: \(newValue)")
      propsData = Data()
    }
  }
  
  init(aid: String, name: String?, living: Bool, lastUpdated: Date, ids: Array<String>?, props: Dictionary<String,Any>) {
    self.aid = aid
    self.name = name
    self.living = living
    self.lastUpdated = lastUpdated
    self.ids = ids
    self.existsInDatabase = false
    self.props = props
  }
  
  private enum CodingKeys: String, CodingKey {
    case aid, name, living, lastUpdated, ids, existsInDatabase
    case propsData = "props"
  }
  
  typealias ModelType = Animal
  static let tableName = "Animal"
  let existsInDatabase: Bool
  var primaryKeys: Array<CodingKey> { return [CodingKeys.aid] }
  var secondaryKeys: Array<CodingKey> { return [] }
  static let syncable = true
}
