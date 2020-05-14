# sModel

sModel is a Swift framework written on top of FMDB to provide:
  - Simple management of your database schema (including schema updates)
  - Simple mapping of database rows to Swift objects
  - Batch updates for improved performance on large updates
  - Simplified handling of local data that gets synchronized with external data

The sModel library has been used for many years on multiple apps found in the AppStore.  This code is production ready and has been battle tested by millions of
users across multiple apps. Compatible with Swift 5.

## DB Schema Management

sModel will take an array of `sql` strings and execute them against your database.  The order in which these `sql` strings 
are executed matters so we recommend storing them in an array.  Each `sql` string is guaranteed to run once and only once for the 
lifetime of your app's installation on a device.  Simply add a new `sql` string to the end of your array to
adjust your schema as your app requires and the next time the app runs, sModel will update your db schema.

NOTE: Never remove old `sql` strings.  These strings will be executed for new installs and will ensure that the database
schema is consistently constructed on all devices.

```swift
let defs: [String] = ["CREATE TABLE \"Thing\" (\"tid\" TEXT PRIMARY KEY, \"name\" TEXT);"]
try? DBManager.open(nil, dbDefs: defs)
```

### Bad Upgrade Recovery

If a database file is corrupted or can't be updated for some reason, the system will try and recover
by deleting the existing database and initializing fresh.   

## Object Mapping

sModel will read data out of your database and map it into your models. For this to
work, you simply adopt the `ModelDef` protocol. Here's an example
model struct to match our db schema definition above.

```swift
struct Thing: ModelDef {
  var tid: String
  var name: String?

  typealias ModelType = Thing
  static let tableName = "Thing"
  var primaryKeys: Array<CodingKey> { return [CodingKeys.tid] }
  var secondaryKeys: Array<CodingKey> { return [] }
}
```
sModel favors being explicit rather than infering information about your configuration.  That is why you will need
to specify the name of the database table your model object will be stored in.  This explicitness avoids any "magic" and
provides you flexibility to configure things however makes sense for your project.

`ModelDef`s can safely use properties of type Int, Double, Bool, String, and Date.  You can even have properties that are 
enums as long as the enum conforms to the `Codable` protocol. 

## Inserts/Updates

Inserting an object into the database is as simple as creating an instance of that object, populating
it with data, and calling `save`.

```swift
let thing = Thing(tid: "tid1", name: "thing 1")
try? thing.save()
```

To update an existing object, just modify its properties and call `save`.

Note: If a call to `save` results in a constraint violation, by default the system will throw
a `ModelError.duplicate` error that contains the existing model object from the database that caused the constraint violation. 
Handling of constraint violations can be changed table by table by adopting the `SyncableModel` protocol
or globably via the `DBManager.blindlyReplaceDuplicates` flag.  See comments 
on those properties for details.

## Handling Syncable Data

`ModelDef`s can be flagged as syncable by implementing the `SyncableModel` protocol.  This is helpful
when you have data in your database that might be changed locally while you are getting updates from
an external source (e.g., updates from a server).  A `SyncableModel` will prevent local changes from being
overwritten by server updates.  This is accomplished by using the `syncStatus` and  `syncInFlightStatus` fields to
track the current sync state of the row.  The system will not allow rows that are not currently synced to be updated
using only a secondary key.  This assumes that your table's primary key is a local only value and server updates will only
be providing a value for the secondary key.

### Sync States

Correctly handling sync states is important if you are using `SyncableModel`s.  Row updates will only occur if:

1. You provide the primary key for the row
OR
2. You provide the secondary key for the row and the `syncStatus` and `syncInFlightStatus` properties are both set to `.synced` in the database.


## Sticky Properties

A sticky property is a nullable property that cannot be set to null once it's been given a value. This is helpful
for properties that are expensive to compute but are nice to retain across object updates.  `ModelDef`s can be flagged as 
containing sticky properties by implementing the `StickyProperties` protocol.


## Batch Processing

Managing objects using the `save` or `delete` methods works great with smaller sets of data 
but has a noticable performance hit when dealing with large amounts of data.  The 
`DBManager.executeStatements` method will take an array of statements and execute them 
all as part of a single database transaction.  That means if one statement fails all of the changes 
are rolled back which prevents your database from getting into a corrupted state.  It also 
dramatically improves the speed in which data can be added/updated/removed from the database. 
Database statements can either be generated manually or via a `ModelDef` object's 
`createSaveStatement` and `createDeleteStatement` methods.

## Queries

Querying data out of the database is also very straightforward.  Each model object has
a set of static methods that can be used to query the database.

```swift
let things = Thing.allInstances() //Returns Array<Thing> that holds every instance of `Thing`

// Where clauses
let thing = Thing.firstInstanceWhere("tid = ?", "tid1") //Returns a Thing?
let someThings = Thing.instancesWhere("tid in (?, ?)", "tid1", "tid2") //Return Array<Thing> for each `Thing` that matches the where clause
```

## Full Working Example

To see how all the parts work together, a full working example is available in the `sModelTests/example` folder.  This includes schema
definition files, model examples, and code exercising all of the CRUD operations available in sModel.  The other unit tests can also be
used to see how each of the public apis can be used.

## Running Locally

To run the tests locally:
 - Install Carthage
 - In the root folder of the project, run `carthage update --platform ios`
 - Run the unit tests from XCode

