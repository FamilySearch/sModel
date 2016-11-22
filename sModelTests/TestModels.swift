import Foundation
import sModel

class Thing: BaseModel {
  var tid = ""
  var name: String? = nil
  var other = 0
  var otherDouble = 0.0
  
  var calledDidDelete = false

  static let sqlTableName = "Thing"
  static let columns = [
    ColumnMeta(name: "tid", type: .text, primaryKey: true),
    ColumnMeta(name: "name", type: .text, primaryKey: false),
    ColumnMeta(name: "other", type: .int, primaryKey: false),
    ColumnMeta(name: "otherDouble", type: .real, primaryKey: false)
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
    ColumnMeta(name: "aid", type: .text, primaryKey: true),
    ColumnMeta(name: "name", type: .text, primaryKey: false),
    ColumnMeta(name: "living", type: .int, primaryKey: false),
    ColumnMeta(name: "lastUpdated", type: .date, primaryKey: false),
    ColumnMeta(name: "ids", type: .array, primaryKey: false),
    ColumnMeta(name: "props", type: .dictionary, primaryKey: false)
  ]
}

extension Animal: ModelDef {
  typealias ModelType = Animal
}
