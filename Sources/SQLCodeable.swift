import Foundation

public struct SQLElements {
  let tableName: String
  let primaryKeys: Array<SQLColumn>
  let secondaryKeys: Array<SQLColumn>
  let columns: Array<SQLColumn>
}

public struct SQLColumn {
  let clause: String
  let value: Any?
  let isPrimaryKey: Bool
  let isSecondaryKey: Bool
}

public enum SQLEncoderError: Error {
  case typeNotConformingToEncodable(Any)
}

public protocol SQLCodable: Codable {
  var tableName: String { get }
  var primaryKeys: Array<CodingKey> { get }
  var secondaryKeys: Array<CodingKey> { get }
}

public class SQLEncoder: Encoder {
  public var codingPath: [CodingKey] = []
  public var userInfo: [CodingUserInfoKey : Any] = [:]
  
  fileprivate var primaryKeys: Array<SQLColumn> = []
  fileprivate var secondaryKeys: Array<SQLColumn> = []
  fileprivate var columns: Array<SQLColumn> = []
  fileprivate var rootValue: SQLCodable
  
  init(rootValue: SQLCodable) {
    self.rootValue = rootValue
  }
  
  static func encode(_ value: SQLCodable) throws -> SQLElements {
    let encoder = SQLEncoder(rootValue: value)
    try value.encode(to: encoder)
    let elements = SQLElements(tableName: value.tableName, primaryKeys: encoder.primaryKeys, secondaryKeys: encoder.secondaryKeys, columns: encoder.columns)
    return elements
  }
  
  public func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
    let container = SQLKeyedEncodingContainer<Key>(encoder: self, codingPath: codingPath)
    return KeyedEncodingContainer(container)
  }
  
  public func unkeyedContainer() -> UnkeyedEncodingContainer {
    preconditionFailure("Not implemented")
  }
  
  public func singleValueContainer() -> SingleValueEncodingContainer {
    preconditionFailure("Not implemented")
  }
  
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
  
  private func _encode(_ value: Any, key: CodingKey) {
    let column = SQLColumn(clause: "\(key.stringValue) = ?", value: value, isPrimaryKey: isPrimary(key: key), isSecondaryKey: isSecondary(key: key))
    if column.isPrimaryKey {
      primaryKeys.append(column)
    }
    if column.isSecondaryKey {
      secondaryKeys.append(column)
    }
    columns.append(column)
  }
  
  func encode(_ value: String, key: CodingKey) { _encode(value, key: key) }
  func encode(_ value: Int, key: CodingKey) { _encode(value, key: key) }
  func encode(_ value: UInt, key: CodingKey) { _encode(value, key: key) }
  func encode(_ value: Float, key: CodingKey) { _encode(value, key: key) }
  func encode(_ value: Double, key: CodingKey) { _encode(value, key: key) }
  func encode(_ value: Bool, key: CodingKey) { _encode(value, key: key) }
  func encode(_ value: Data, key: CodingKey) { _encode(value, key: key)}
  
  func encodeNil(_ key: CodingKey) {
    columns.append(SQLColumn(clause: "\(key.stringValue) = NULL", value: nil, isPrimaryKey: isPrimary(key: key), isSecondaryKey: isSecondary(key: key)))
  }
  
  private struct SQLKeyedEncodingContainer<K: CodingKey>: KeyedEncodingContainerProtocol {
    typealias Key = K
    
    var encoder: SQLEncoder
    public var codingPath: [CodingKey]
    
    public mutating func encode(_ value: Bool, forKey key: Key) throws {
      encoder.encode(value, key: key)
    }
    
    public mutating func encode(_ value: Int, forKey key: Key) throws {
      encoder.encode(value, key: key)
    }
    
    public mutating func encode(_ value: Int8, forKey key: Key) throws {
      encoder.encode(Int(value), key: key)
    }
    
    public mutating func encode(_ value: Int16, forKey key: Key) throws {
      encoder.encode(Int(value), key: key)
    }
    
    public mutating func encode(_ value: Int32, forKey key: Key) throws {
      encoder.encode(Int(value), key: key)
    }
    
    public mutating func encode(_ value: Int64, forKey key: Key) throws {
      encoder.encode(Int(value), key: key)
    }
    
    public mutating func encode(_ value: UInt, forKey key: Key) throws {
      encoder.encode(value, key: key)
    }
    
    public mutating func encode(_ value: UInt8, forKey key: Key) throws {
      encoder.encode(UInt(value), key: key)
    }
    
    public mutating func encode(_ value: UInt16, forKey key: Key) throws {
      encoder.encode(UInt(value), key: key)
    }
    
    public mutating func encode(_ value: UInt32, forKey key: Key) throws {
      encoder.encode(UInt(value), key: key)
    }
    
    public mutating func encode(_ value: UInt64, forKey key: Key) throws {
      encoder.encode(UInt(value), key: key)
    }
    
    public mutating func encode(_ value: Float, forKey key: Key) throws {
      encoder.encode(value, key: key)
    }
    
    public mutating func encode(_ value: Double, forKey key: Key) throws {
      encoder.encode(value, key: key)
    }
    
    public mutating func encode(_ value: String, forKey key: Key) throws {
      encoder.encode(value, key: key)
    }
    
    public mutating func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
      if let a = value as? Array<AnyObject> {
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
      } else {
        throw SQLEncoderError.typeNotConformingToEncodable(value)
      }
    }
    
    mutating func encodeNil(forKey key: K) throws {
      encoder.encodeNil(key)
    }
    
    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: K) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
      preconditionFailure("Not implemented")
    }
    
    mutating func nestedUnkeyedContainer(forKey key: K) -> UnkeyedEncodingContainer {
      preconditionFailure("Not implemented")
    }
    
    mutating func superEncoder() -> Encoder {
      preconditionFailure("Not implemented")
    }
    
    mutating func superEncoder(forKey key: K) -> Encoder {
      preconditionFailure("Not implemented")
    }
  }
}
