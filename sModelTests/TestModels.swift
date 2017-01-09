import Foundation
import sModel

class Thing: BaseModel {
  var localId = BaseModel.generateUUID()
  var tid = ""
  var name: String? = nil
  var other = 0
  var otherDouble = 0.0
  
  var calledDidDelete = false

  static let sqlTableName = "Thing"
  static let columns = [
    ColumnMeta(name: "localId", type: .text, constraint: .primary),
    ColumnMeta(name: "tid", type: .text, constraint: .serverUnique),
    ColumnMeta(name: "name", type: .text),
    ColumnMeta(name: "other", type: .int),
    ColumnMeta(name: "otherDouble", type: .real)
  ]

  override func didDelete() {
    super.didDelete()
    calledDidDelete = true
  }
}

extension Thing: ModelDef {
  typealias ModelType = Thing
}


class Animal: BaseModel {
  var aid = ""
  var name: String? = nil
  var living = false
  var lastUpdated = Date(timeIntervalSince1970: 0)
  var ids = [String]()
  var props = ResultDictionary()

  static let sqlTableName = "Animal"
  static let columns = [
    ColumnMeta(name: "aid", type: .text, constraint: .primary),
    ColumnMeta(name: "name", type: .text),
    ColumnMeta(name: "living", type: .int),
    ColumnMeta(name: "lastUpdated", type: .date),
    ColumnMeta(name: "ids", type: .array),
    ColumnMeta(name: "props", type: .dictionary)
  ]
}

extension Animal: ModelDef {
  typealias ModelType = Animal
}
