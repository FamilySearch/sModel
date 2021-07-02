//
//  Utils.swift
//  sModel iOS
//
//  Created by Stephen Lynn on 5/14/20.
//  Copyright © 2020 FamilySearch. All rights reserved.
//

import Foundation

#if canImport(CryptoKit)
import CryptoKit
#endif

struct Utils {
  static func selectNewDefs(currentVersion: Int, defs: [String]) -> String? {
    guard currentVersion < defs.count else { return nil }
    return defs.suffix(from: currentVersion).joined(separator: "\n\n")
  }
  
  static func selectProcessedDefs(currentVersion: Int, defs: [String]) -> String? {
    guard currentVersion > 0 else { return nil }
    guard currentVersion <= defs.count else { return nil }
    return defs.prefix(upTo: currentVersion).joined(separator: "\n\n")
  }
  
  static func generateHash(string: String) -> String {
    guard let defData = string.data(using: .utf8) else {
      preconditionFailure("Problem converting string into utf8 data representation: \(self)")
    }
    
    if #available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *) {
      let digest = Insecure.MD5.hash(data: defData)
      return digest.map({ String(format: "%02hhx", $0) }).joined()
      
    } else {
      Log.warn("OS doesn't support CryptoKit so bypassing hash check by always returning empty string")
      return "\(defData.count)"
    }
  }
}
