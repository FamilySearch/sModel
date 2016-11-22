import XCTest
@testable import sModel

class MultiThreadTests: XCTestCase {

  override func setUp() {
    super.setUp()

    var paths = Bundle(for: type(of: self)).paths(forResourcesOfType: "sql", inDirectory: nil)
    paths.sort()

    try! DBManager.open(nil, dbDefFilePaths: paths)
  }

  override func tearDown() {
    DBManager.close()
    super.tearDown()
  }

  func testSimultaneousAccessAcrossThreads() {
    let expectation = self.expectation(description: "multi thread db access test")
    var finished = false

    @discardableResult
    func insertThing(_ tid: String, name: String) -> Thing {
      let newThing = Thing()
      newThing.tid = tid
      newThing.name = name
      newThing.save()

      return newThing
    }

    //Add a bunch of objects to the db on background thread and read them out on the main thread at the same time
    let iterationCount = 500
    DispatchQueue.global(qos: .default).async {
      for i in 1...iterationCount {
        insertThing("tid\(i)", name: "thing \(i)")

        DispatchQueue.main.async {
          let things = Thing.allInstances()
          if things.count == iterationCount && !finished {
            finished = true
            expectation.fulfill()
          }
        }
      }
    }

    self.waitForExpectations(timeout: 10) { (error) -> Void in
      //no cleanup needed
    }
  }
}
