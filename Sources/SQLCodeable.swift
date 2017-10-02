import FMDB
import Foundation

public typealias SQLArrayOfStrings = Array<String>

public struct SQLElements {
  let tableName: String
  let syncable: Bool
  let primaryKeys: Array<SQLColumn>
  let secondaryKeys: Array<SQLColumn>
  let columns: Array<SQLColumn>
}

public struct SQLColumn {
  let name: String
  let clause: String
  let value: Any?
  let isPrimaryKey: Bool
  let isSecondaryKey: Bool
}

public enum SQLEncoderError: Error {
  case typeNotConformingToEncodable(key: String, Any)
}

public enum SQLDecoderError: Error {
  case missingKey(String)
  case missingValue(String)
  case typeMismatch(String)
  case dataCorrupted(String)
}

// class restriction is because isDeleted/existsInDatabase can't be defined on a value type without making them mutating functions.
public protocol SQLCodable: SQLEncodable, SQLDecodable {
  var existsInDatabase: Bool { get }
}

public protocol SQLEncodable: Encodable {
  static var tableName: String { get }
  static var syncable: Bool { get }
  var primaryKeys: Array<CodingKey> { get }
  var secondaryKeys: Array<CodingKey> { get }
}

public protocol SQLDecodable: Decodable {
  static var tableName: String { get }
  var primaryKeys: Array<CodingKey> { get }
  var secondaryKeys: Array<CodingKey> { get }
  
  init(fromSQL decoder: SQLDecoder) throws
}
public extension SQLDecodable {
  public init(fromSQL decoder: SQLDecoder) throws {
    try self.init(from: decoder)
  }
}

public class SQLEncoder: Encoder {
  public var codingPath: [CodingKey] = []
  public var userInfo: [CodingUserInfoKey : Any] = [:]
  
  fileprivate var primaryKeys: Array<SQLColumn> = []
  fileprivate var secondaryKeys: Array<SQLColumn> = []
  fileprivate var columns: Array<SQLColumn> = []
  fileprivate var rootValue: SQLEncodable
  
  init(rootValue: SQLEncodable) {
    self.rootValue = rootValue
  }
  
  static func encode(_ value: SQLEncodable) throws -> SQLElements {
    do {
      let encoder = SQLEncoder(rootValue: value)
      try value.encode(to: encoder)
      let elements = SQLElements(tableName: type(of: value).tableName, syncable: type(of: value).syncable, primaryKeys: encoder.primaryKeys, secondaryKeys: encoder.secondaryKeys, columns: encoder.columns)
      return elements
    } catch {
      print("Error encoding sql: \(error)")
      throw error
    }
  }
  
  public func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
    let container = SQLKeyedEncodingContainer<Key>(encoder: self, codingPath: codingPath)
    return KeyedEncodingContainer(container)
  }
  
  public func unkeyedContainer() -> UnkeyedEncodingContainer { preconditionFailure("Not implemented") }
  public func singleValueContainer() -> SingleValueEncodingContainer { preconditionFailure("Not implemented") }
  
  private func isPrimary(key: CodingKey) -> Bool {
    let keyString = key.stringValue
    for k in rootValue.primaryKeys {
      if k.stringValue == keyString {
        return true
      }
    }
    return false
  }
  
  private func isSecondary(key: CodingKey) -> Bool {
    let keyString = key.stringValue
    for k in rootValue.secondaryKeys {
      if k.stringValue == keyString {
        return true
      }
    }
    return false
  }
  
  private func _encode(_ value: Any?, key: CodingKey) {
    guard key.stringValue != "existsInDatabase" else { return }
    guard let value = value else {
      encodeNil(key)
      return
    }
    
    let column = SQLColumn(name: key.stringValue, clause: "\(key.stringValue) = ?", value: value, isPrimaryKey: isPrimary(key: key), isSecondaryKey: isSecondary(key: key))
    if column.isPrimaryKey {
      primaryKeys.append(column)
    }
    if column.isSecondaryKey {
      secondaryKeys.append(column)
    }
    columns.append(column)
  }
  
  func encode(_ value: String?, key: CodingKey) { _encode(value, key: key) }
  func encode(_ value: Int?, key: CodingKey) { _encode(value, key: key) }
  func encode(_ value: UInt?, key: CodingKey) { _encode(value, key: key) }
  func encode(_ value: Float?, key: CodingKey) { _encode(value, key: key) }
  func encode(_ value: Double?, key: CodingKey) { _encode(value, key: key) }
  func encode(_ value: Bool?, key: CodingKey) { _encode(value, key: key) }
  func encode(_ value: Data?, key: CodingKey) { _encode(value, key: key)}
  
  func encodeNil(_ key: CodingKey) {
    columns.append(SQLColumn(name: key.stringValue, clause: "\(key.stringValue) = NULL", value: nil, isPrimaryKey: isPrimary(key: key), isSecondaryKey: isSecondary(key: key)))
  }
  
  private struct SQLKeyedEncodingContainer<K: CodingKey>: KeyedEncodingContainerProtocol {
    typealias Key = K
    
    var encoder: SQLEncoder
    public var codingPath: [CodingKey]
    
    mutating func encode(_ value: Bool, forKey key: Key) throws { encoder.encode(value, key: key) }
    mutating func encode(_ value: Int, forKey key: Key) throws { encoder.encode(value, key: key) }
    mutating func encode(_ value: Int8, forKey key: Key) throws { preconditionFailure("Not implemented") }
    mutating func encode(_ value: Int16, forKey key: Key) throws { preconditionFailure("Not implemented") }
    mutating func encode(_ value: Int32, forKey key: Key) throws { preconditionFailure("Not implemented") }
    mutating func encode(_ value: Int64, forKey key: Key) throws { preconditionFailure("Not implemented") }
    mutating func encode(_ value: UInt, forKey key: Key) throws { preconditionFailure("Not implemented") }
    mutating func encode(_ value: UInt8, forKey key: Key) throws { preconditionFailure("Not implemented") }
    mutating func encode(_ value: UInt16, forKey key: Key) throws { preconditionFailure("Not implemented") }
    mutating func encode(_ value: UInt32, forKey key: Key) throws { preconditionFailure("Not implemented") }
    mutating func encode(_ value: UInt64, forKey key: Key) throws { preconditionFailure("Not implemented") }
    mutating func encode(_ value: Float, forKey key: Key) throws { encoder.encode(value, key: key) }
    mutating func encode(_ value: Double, forKey key: Key) throws { encoder.encode(value, key: key) }
    mutating func encode(_ value: String, forKey key: Key) throws { encoder.encode(value, key: key) }
    mutating func encodeNil(forKey key: K) throws { encoder.encodeNil(key) }
    
    mutating func encodeIfPresent(_ value: Int?, forKey key: K) throws { encoder.encode(value, key: key) }
    mutating func encodeIfPresent(_ value: Bool?, forKey key: K) throws { encoder.encode(value, key: key) }
    mutating func encodeIfPresent(_ value: Float?, forKey key: K) throws { encoder.encode(value, key: key) }
    mutating func encodeIfPresent(_ value: Double?, forKey key: K) throws { encoder.encode(value, key: key) }
    mutating func encodeIfPresent(_ value: String?, forKey key: K) throws { encoder.encode(value, key: key) }
    mutating func encodeIfPresent<T>(_ value: T?, forKey key: K) throws where T : Encodable {
      guard let value = value else {
        try encodeNil(forKey: key)
        return
      }
      try encode(value, forKey: key)
    }
    
    mutating func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
      if let date = value as? Date {
        encoder.encode(date.timeIntervalSince1970, key: key)
        
      } else if let a = value as? Array<AnyObject> {
        do {
          let data = try PropertyListSerialization.data(fromPropertyList: a, format: PropertyListSerialization.PropertyListFormat.binary, options: 0)
          encoder.encode(data, key: key)
        } catch {
          preconditionFailure("Unable to serialize array for INSERTTABLENAMEHERE.\(key.stringValue): \(error)")
        }
        
      } else if let d = value as? ResultDictionary {
        do {
          let data = try PropertyListSerialization.data(fromPropertyList: d, format: PropertyListSerialization.PropertyListFormat.binary, options: 0)
          encoder.encode(data, key: key)
        } catch {
          preconditionFailure("Unable to serialize dictionary for INSERTTABLENAMEHERE.\(key.stringValue): \(error)")
        }
      } else if let d = value as? Data {
        encoder.encode(d, key: key)
        
      } else {
        throw SQLEncoderError.typeNotConformingToEncodable(key: key.stringValue, value)
      }
    }
    
    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: K) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey { preconditionFailure("Not implemented") }
    mutating func nestedUnkeyedContainer(forKey key: K) -> UnkeyedEncodingContainer { preconditionFailure("Not implemented") }
    mutating func superEncoder() -> Encoder { preconditionFailure("Not implemented") }
    mutating func superEncoder(forKey key: K) -> Encoder { preconditionFailure("Not implemented") }
  }
}

public class SQLDecoder: Decoder {
  public var codingPath: [CodingKey] = []
  public var userInfo: [CodingUserInfoKey : Any] = [:]
  
  fileprivate let result: FMResultSet
  
  public init(result: FMResultSet) {
    self.result = result
  }
  
  public func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
    let container = SQLKeyedDecodingContainer<Key>(referencing: self)
    return KeyedDecodingContainer(container)
  }
  
  public func unkeyedContainer() throws -> UnkeyedDecodingContainer { preconditionFailure("Not implemented") }
  public func singleValueContainer() throws -> SingleValueDecodingContainer { preconditionFailure("Not implemented") }
  
  private struct SQLKeyedDecodingContainer<K: CodingKey>: KeyedDecodingContainerProtocol {
    typealias Key = K
    
    private let decoder: SQLDecoder
    
    var codingPath: [CodingKey]
    
    fileprivate init(referencing decoder: SQLDecoder) {
      self.decoder = decoder
      self.codingPath = decoder.codingPath
    }
    
    public var allKeys: [Key] {
      return Array<Key>()
    }
    
    public func contains(_ key: Key) -> Bool {
      return true
    }
    
    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: K) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey { preconditionFailure("Not implemented") }
    func nestedUnkeyedContainer(forKey key: K) throws -> UnkeyedDecodingContainer { preconditionFailure("Not implemented") }
    func superDecoder() throws -> Decoder { preconditionFailure("Not implemented") }
    func superDecoder(forKey key: K) throws -> Decoder { preconditionFailure("Not implemented") }

    public func decodeNil(forKey key: Key) throws -> Bool {
      return decoder.result.columnIsNull(key.stringValue)
    }
    
    public func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
      if key.stringValue == "existsInDatabase" {
        return true
      }
      return decoder.result.bool(forColumn: key.stringValue)
    }
    
    public func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
      return Int(decoder.result.int(forColumn: key.stringValue))
    }
    
    public func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
      return UInt(decoder.result.unsignedLongLongInt(forColumn: key.stringValue))
    }
    
    public func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 { preconditionFailure("Not implemented") }
    public func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 { preconditionFailure("Not implemented") }
    public func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 { preconditionFailure("Not implemented") }
    public func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 { preconditionFailure("Not implemented") }
    public func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 { preconditionFailure("Not implemented") }
    public func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 { preconditionFailure("Not implemented") }
    public func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 { preconditionFailure("Not implemented") }
    public func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 { preconditionFailure("Not implemented") }
    
    public func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
      let double = decoder.result.double(forColumn: key.stringValue)
      return Float(double)
    }
    
    public func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
      return decoder.result.double(forColumn: key.stringValue)
    }
    
    public func decode(_ type: String.Type, forKey key: Key) throws -> String {
      return decoder.result.string(forColumn: key.stringValue)
    }
    
    public func decode<T: Decodable>(_ type: T.Type, forKey key: Key) throws -> T {
      if type == Date.self {
        let double = decoder.result.double(forColumn: key.stringValue)
        let date = Date(timeIntervalSince1970: double)
        if let returnItem = date as? T {
          return returnItem
        }
        throw SQLDecoderError.typeMismatch(key.stringValue)
        
      } else if type == SQLArrayOfStrings.self {
        guard let data = decoder.result.data(forColumn: key.stringValue) else {
          throw SQLDecoderError.missingValue(key.stringValue)
        }
        guard let a = try PropertyListSerialization.propertyList(from: data, options: PropertyListSerialization.MutabilityOptions(), format: nil) as? T else {
          throw SQLDecoderError.dataCorrupted(key.stringValue)
        }
        return a
        
      } else if type == Data.self {
        let data = decoder.result.data(forColumn: key.stringValue)
        if let returnItem = data as? T {
          return returnItem
        }
        throw SQLDecoderError.typeMismatch(key.stringValue)
      }
      preconditionFailure("Not implemented")
    }
  }
}
