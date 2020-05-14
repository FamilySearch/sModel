//
//  ExampleUsage.swift
//  sModelTests
//
//  Created by Stephen Lynn on 2/22/19.
//  Copyright © 2019 FamilySearch. All rights reserved.
//

import XCTest
import sModel

class ExampleUsage: XCTestCase {

  override func setUp() {
    super.setUp()
    
    //You can control what logging is output by setting a different `logLevel` or by providing your own custom
    //`Logger` by implementing the `Logger` protocol and setting the `Log.logger` property to an instances of your
    //custom `Logger`.
    Log.logLevel = .error
    
    try! DBManager.open(nil, dbDefs: ExampleDBDefs.defs)
  }
  
  override func tearDown() {
    DBManager.close()
    super.tearDown()
  }
  
  func testShowExamplesOfHowToUseSModel() {
    //Add People to database
    var person = Person(id: "p1", name: "Abe", email: nil, age: 10, active: true)
    try? person.save()
    
    let person2 = Person(id: "p2", name: "Bob", email: "bob@email.com", age: 20, active: false)
    try? person2.save()
    
    //Read people from database
    XCTAssertEqual(Person.allInstances().count, 2)
    XCTAssertEqual(Person.instancesWhere("id = ?", params: "p2").count, 1)
    
    //Update person in the database
    let fullName = "Abe Lincoln"
    person.name = fullName
    try? person.save()
    XCTAssertEqual(Person.firstInstanceWhere("id = ?", params: person.id)!.name, fullName)
    
    //Delete person from database
    person2.delete()
    XCTAssertEqual(Person.allInstances().count, 1)
  }
  
  func testShowExampleOfHowtoUseSyncableModel() {
    //Add local only message to db
    var message = Message(messageId: "m1", content: "message 1", createdOn: Date(), ownerPersonId: "p1")
    try? message.save()
    
    //Attempt to update the message using a new object with the same secondary key (messageId).
    //This is similar to reading data from a server with the same message id.  Since the sync properties are
    //not both `.synced` this will fail.
    let messageFromServer = Message(messageId: "m1", content: "message 1 from server", createdOn: Date(), ownerPersonId: "p1")
    do {
      try messageFromServer.save()
    } catch ModelError<Message>.duplicate(let existingItem) { //The duplicate error will return you the existing item in the database
      XCTAssertEqual(existingItem.content, message.content)
    } catch {
      XCTFail()
    }
    
    //Set the message sync properties to synced
    message.syncStatus = .synced
    message.syncInFlightStatus = .synced
    try? message.save()
    
    do {
      try messageFromServer.save()
    } catch ModelError<Message>.duplicate(let existingItem) { //The duplicate error will return you the existing item in the database
      //This time the row in the database has been updated with the data from `messageFromServer`
      XCTAssertEqual(existingItem.content, messageFromServer.content)
      //This update preservese the `primaryKey`, `syncStatus`, and `syncInFlightStatus` values of the original `message` object.
      //This is important in case the primary key of this object is being used as a foreign key in another table.
      XCTAssertNotEqual(existingItem.localId, messageFromServer.localId)
    } catch {
      XCTFail()
    }
    
    //Now our message object refreshed from the database will have the updated values
    if let refreshedMessage = message.readFromDB() {
      XCTAssertEqual(refreshedMessage.localId, message.localId)
      XCTAssertEqual(refreshedMessage.content, messageFromServer.content)
    }
    
  }
  
  func testShowExampleOfHowtoUseBatchStatements() {
    //If you are loading a lot of data into the database you can perform the database operations in batches.  This
    //significantly improves performance and performs all the changes inside a single database transaction so if one
    //of the operations fails then the whole batch is rolled back which helps avoid database corruption.
    
    //There are two approaches to loading data in batches. The first is the most convenient but is slightly slower.  This
    //approach creates `Person` objects but instead of saving them creates a list of `StatementParts` that are then
    //sent to the database in a batch.
    let person = Person(id: "p1", name: "Abe", email: nil, age: 10, active: true)
    let person2 = Person(id: "p2", name: "Bob", email: "bob@email.com", age: 20, active: false)
    let person3 = Person(id: "p3", name: "Cloe", email: nil, age: 30, active: true)
    
    do {
      let statements = [try person.createSaveStatement(), try person2.createSaveStatement(), try person3.createSaveStatement()]
      try DBManager.executeStatements(statements) { (_, _) in }
    } catch {
      XCTFail()
    }
    
    XCTAssertEqual(Person.allInstances().count, 3)
    
    //Clear the data
    DBManager.truncateAllTables()
    XCTAssertEqual(Person.allInstances().count, 0)
    
    //The second approach uses less memory by avoiding creation of the different `Person` instances but requires you
    //to generate the sql statements needed to create the database objects. Using this approach requires you to handle
    //insertion errors and any potential constraint conflicts instead of allowing sModel to handle those things for you.
    let insertString = "INSERT INTO Person (id,name,email,age,active) VALUES (?,?, NULL,?,?)"
    var statements = [StatementParts]()
    statements.append(StatementParts(sql: insertString, values: ["p1", "Abe", 10, true], type: .insert))
    statements.append(StatementParts(sql: insertString, values: ["p2", "Bob", 20, false], type: .insert))
    statements.append(StatementParts(sql: insertString, values: ["p3", "Cloe", 30, true], type: .insert))
    
    do {
      try DBManager.executeStatements(statements) { (_, _) in }
    } catch {
      XCTFail()
    }
    
    XCTAssertEqual(Person.allInstances().count, 3)
    
    //This approach can also be used to submit custom SQL statements to the database
    let statement = StatementParts(sql: "SELECT * FROM Person WHERE id IN (?, ?) ORDER BY name DESC", values: ["p1", "p3"], type: .query)
    do {
      try DBManager.executeStatement(statement, resultHandler: { (result) in
        guard let result = result else { XCTFail(); return }
        do {
          var people = [Person]()
          while result.next() {
            let person = try Person(fromSQL: SQLDecoder(result: result))
            people.append(person)
          }
          
          XCTAssertEqual(people.count, 2)
          XCTAssertEqual(people[0].name, "Cloe")
          XCTAssertEqual(people[1].name, "Abe")
          
        } catch {
          XCTFail()
        }
      })
    } catch {
      XCTFail()
    }
  }
}
