//
//  Utils.swift
//  sModel iOS
//
//  Created by Stephen Lynn on 5/14/20.
//  Copyright © 2020 FamilySearch. All rights reserved.
//

import Foundation

struct Utils {
  static func selectDefs(currentVersion: Int, defs: [String]) -> String? {
    guard currentVersion < defs.count else { return nil }
    return defs.suffix(from: currentVersion).joined(separator: "\n\n")
  }
}

extension String.StringInterpolation {
  mutating func appendInterpolation(table value: ModelDef.Type) {
    appendLiteral("\(value.namespace)_\(value.tableName)")
  }
}
