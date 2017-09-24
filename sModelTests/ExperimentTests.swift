//
//  ExperimentTests.swift
//  sModelTests
//
//  Created by Stephen Lynn on 9/20/17.
//  Copyright © 2017 FamilySearch. All rights reserved.
//

import XCTest
@testable import sModel

class ExperimentTests: XCTestCase {
  
  struct Person: SQLCodable {
    var localId = BaseModel.generateUUID()
    var tid: String
    var name: String?
    var other: Int
    var otherDouble: Double
    
    var tableName: String { return "Thing" }
    var primaryKeys: Array<CodingKey> { return [CodingKeys.localId] }
    var secondaryKeys: Array<CodingKey> { return [CodingKeys.tid] }
  }
  
  override func setUp() {
    super.setUp()
    var paths = DBManager.getDBDefFiles(bundle: Bundle(for: type(of: self)))!
    paths.sort()
    
    try! DBManager.open(nil, dbDefFilePaths: paths)
  }
  
  override func tearDown() {
    DBManager.close()
    super.tearDown()
  }
  
  func testDecoding() {
    do {
      let statement = StatementParts(sql: "SELECT * FROM Thing", values: [], type: .query)
      try DBManager.executeStatement(statement) { (result) in
        guard let result = result else { return }
        while result.next() {
          let p = try! Person(fromSQL: SQLDecoder(data: result))
          print("Done")
        }
      }
    } catch {
      
    }
  }
  
  func testEncoding() {
    let p = Person(localId: "localId", tid: "tid2", name: "thing2", other: 4, otherDouble: 3.34)
    
    do {
      let e = try SQLEncoder.encode(p)
      print("hit")
    } catch {
      print("Error: \(error)")
    }
  }
  
}
