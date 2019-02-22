# sModel

sModel is a Swift framework written on top of FMDB to provide:
  - Simple management of your database schema (including schema updates)
  - Simple mapping of database rows to Swift objects
  - Batch updates for improved performance on large updates
  - Easier handling of local data that gets synchronized with the server

The included test project has examples of how to use all of the different features
of sModel.  Compatible with Swift 4.

## DB Schema Management

sModel will take a list of `sql` files and execute them against your
db.  The order in which these `sql` files are executed matters so we recommend following a naming
scheme that make it easy consistently sort them in the same order each time and will result in new files
sorting to the end of the list.  Each `sql` file is guaranteed to run once and only once for the lifetime of your app's
installation on a device.  Simply add a new `sql` file to adjust your schema as your app requires
and the next time the app runs, sModel will update your db schema.

NOTE: Never remove old schema files.  These files will be executed for new installs and will ensure that the database
schema is consistently constructed on all devices.

sModel comes with a set of helpers to open/close your database and to load your `sql` files.

```swift
var paths = DBManager.getDBDefFiles(bundle: nil)!
paths.sort() //You can sort the files however you would like, just stay consistent.

try? DBManager.open(nil, dbDefFilePaths: paths)
```

### Example SQL Schema Definition file

```sql
CREATE TABLE "Thing" (
  "tid" TEXT PRIMARY KEY,
  "name" TEXT
);
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
  static let syncable = false
}
```

## Inserts/Updates

Inserting an object into the database is as simple as creating an instance, populating
it with data, and calling `save`.

```swift
let thing = Thing(tid: "tid1", name: "thing 1")
try? thing.save()
```

To update an existing object, just modify it's properties and call `save`.

Note: If a call to `save` results in a constraint violation, by default the system will throw
a `ModelError.duplicate` error that contains the existing model object from the database. 
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
2. You provide the secondary key for the row and the `syncStatus` and `syncInFlightStatus` properties are both set to `.synced`

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

## Running Locally

To run the tests locally:
 - Install Carthage
 - In the root folder of the project, run `carthage update --platform ios`
 - Run the unit tests from XCode
