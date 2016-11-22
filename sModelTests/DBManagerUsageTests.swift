import XCTest
@testable import sModel

class DBManagerUsageTests: XCTestCase {

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

  func testTruncateAllTables() {
    insertThing("tid1", name: "thing 1")

    guard Thing.firstInstanceWhere("tid = ?", params: "tid1") != nil else {
      XCTFail("dbThing should have had a value")
      return
    }

    DBManager.truncateAllTables()

    guard Thing.firstInstanceWhere("tid = ?", params: "tid1") == nil else {
      XCTFail("dbThing should not have existed in the database")
      return
    }
  }

  func testTruncateAllTables_excludeTable() {
    insertThing("tid1", name: "thing 1")

    let animal = Animal()
    animal.aid = "aid1"
    animal.save()

    guard Thing.firstInstanceWhere("tid = ?", params: "tid1") != nil else {
      XCTFail("Thing should have had a value")
      return
    }
    guard Animal.firstInstanceWhere("aid = ?", params: "aid1") != nil else {
      XCTFail("Animal should have had a value")
      return
    }

    DBManager.truncateAllTables(excludes: ["Thing"])

    guard Thing.firstInstanceWhere("tid = ?", params: "tid1") != nil else {
      XCTFail("Thing should have had a value")
      return
    }
    guard Animal.firstInstanceWhere("aid = ?", params: "aid1") == nil else {
      XCTFail("Animal should not have had a value")
      return
    }
  }

  func testExecuteStatement() {
    insertThing("tid1", name: "thing 1")

    let statement = StatementParts(sql: "Select * from Thing", values: [], type: StatementType.query)

    try! DBManager.executeStatement(statement, resultHandler: { (result) in
      guard let result = result else {
        XCTFail("Should have returned a result")
        return
      }
      XCTAssertTrue(result.next())
    })
  }

  func testExecuteStatement_multipleQueryStatements() {
    insertThing("tid1", name: "thing 1")

    let statement1 = StatementParts(sql: "Select * from Thing", values: [], type: .query)
    let statement2 = StatementParts(sql: "Select * from Thing", values: [], type: .query)
    let statements = [statement1, statement2]

    try! DBManager.executeStatements(statements, resultsHandler: { (results) in
      for result in results {
        guard let result = result else {
          XCTFail("Should have returned a result")
          return
        }
        XCTAssertTrue(result.next())
        XCTAssertEqual("tid1", result.string(forColumn: "tid"))
      }
    })
  }

  func testExecuteStatement_multipleUpdateStatements() {
    let statement1 = StatementParts(sql: "INSERT INTO Thing (tid, name) VALUES (?,?)", values: ["tid1", "thing 1"], type: .update)
    let statement2 = StatementParts(sql: "INSERT INTO Thing (tid, name) VALUES (?,?)", values: ["tid2", "thing 2"], type: .update)
    let statements = [statement1, statement2]

    try! DBManager.executeStatements(statements, resultsHandler: { (results) in
      XCTAssertEqual(2, results.count)
      for result in results {
        guard result == nil else {
          XCTFail("Should have returned a null result")
          return
        }
      }
    })

    XCTAssertEqual(2, Thing.allInstances().count)
  }

  func testExecuteStatement_interleavedSelectUpdateStatements() {
    let statement1 = StatementParts(sql: "INSERT INTO Thing (tid, name) VALUES (?,?)", values: ["tid1", "thing 1"], type: .update)
    let statement2 = StatementParts(sql: "Select * from Thing", values: [], type: .query)
    let statement3 = StatementParts(sql: "INSERT INTO Thing (tid, name) VALUES (?,?)", values: ["tid2", "thing 2"], type: .update)
    let statement4 = StatementParts(sql: "Select * from Thing ORDER BY tid", values: [], type: .query)
    let statements = [statement1, statement2, statement3, statement4]

    try! DBManager.executeStatements(statements, resultsHandler: { (results) in
      XCTAssertEqual(4, results.count)
      for (index, result) in results.enumerated() {
        switch index {
          case 0,2:
            guard result == nil else {
              XCTFail("Should have returned a null result")
              return
            }
          case 1:
            guard let result = result else {
              XCTFail("Should have returned a result")
              return
            }
            XCTAssertTrue(result.next())
            XCTAssertEqual("tid1", result.string(forColumn: "tid"))
          case 3:
            guard let result = result else {
              XCTFail("Should have returned a result")
              return
            }
            XCTAssertTrue(result.next())
            XCTAssertEqual("tid1", result.string(forColumn: "tid"))
            XCTAssertTrue(result.next())
            XCTAssertEqual("tid2", result.string(forColumn: "tid"))
        default:
          XCTFail("Unexpected result case")
        }
      }
    })

    XCTAssertEqual(2, Thing.allInstances().count)
  }

  func testResultDictionariesFromQuery() {
    insertThing("tid1", name: "thing 1")

    let resultDicts = DBManager.resultDictionariesFromQuery("Select * from Thing")
    XCTAssertEqual(1, resultDicts.count)
    for resultDict in resultDicts {
      guard let tid = resultDict["tid"] as? String else {
        XCTFail("Should have returned a tid of type string")
        return
      }
      XCTAssertEqual("tid1", tid)
    }
  }

  @discardableResult
  func insertThing(_ tid: String, name: String) -> Thing {
    let newThing = Thing()
    newThing.tid = tid
    newThing.name = name
    newThing.save()

    return newThing
  }
}
