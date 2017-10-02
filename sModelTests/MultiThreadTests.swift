import XCTest
@testable import sModel

class MultiThreadTests: XCTestCase {

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

  func testSimultaneousAccessAcrossThreads() {
    let expectation = self.expectation(description: "multi thread db access test")
    var finished = false

    @discardableResult
    func insertThing(_ tid: String, name: String) -> Thing {
      let newThing = Thing(tid: tid, name: name, other: 0, otherDouble: 0)
      try? newThing.save()
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
  
  func testEntityIndependence() {
    var tree = Tree(name: "tree 1")
    
    try? tree.save()
    
    let otherTree = tree
    tree.name = "tree 1 - changed"
    XCTAssertNotEqual(tree.name, otherTree.name)
    
    try? tree.save()
    XCTAssertNotEqual(tree.name, otherTree.name)
    
    guard let reloadedTree = otherTree.readFromDB() else {
      XCTFail("Should have been able to read tree from db")
      return
    }
    
    XCTAssertEqual(tree.name, reloadedTree.name)
  }
}
