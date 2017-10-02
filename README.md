# sModel

sModel is a Swift framework written on top of FMDB to provide:
  - Simple management of your database schema (including database updates)
  - Simple mapping of database rows to Swift objects
  - Batch updates for improved performance on large updates

The included test project has examples of how to use all of the different features
of sModel.

## DB Schema Management

sModel will take a list of `sql` files (sorted alphabetically) and execute them against your
db.  Each `sql` file is guaranteed to run once and only once for the lifetime of your app's
installation on a device.  Simply add a new `sql` file to adjust your schema as your app requires
and the next time the app runs, sModel will update your db schema.

sModel comes with a set of helpers to open/close your database and to load your `sql` files.

```swift
var paths = DBManager.getDBDefFiles(bundle: nil)!
paths.sort() //You can sort the files however you would like, just stay consistent.

try? DBManager.open(nil, dbDefFilePaths: paths)
```

### Example SQL files

```sql
CREATE TABLE "Thing" (
  "tid" TEXT PRIMARY KEY,
  "name" TEXT
);
```

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
  let existsInDatabase: Bool
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

Note: If a call to `save` results in a constraint violation, by default the system will throw a `ModelError.duplicate` error that contains the current model object from the database. Handling of constraint violations can be changed table by table via the `ModelDef.syncable` property or globably via the `DBManager.blindlyReplaceDuplicates` flag.  See comments on those properties for details.

## Batch Processing

Managing objects using the `save` or `delete` methods works great with smaller sets of data but has a noticable performance hit when dealing with large amounts of data.  The `DBManager.executeStatements` method will take an array of statements and execute them all as part of a single database transaction.  That means one statement fails all of the changes are rolled back which prevents your database from getting into a corrupted state.  It also dramatically improves the speed in which data can be added/updated/removed from the database. Database statements can either be generated manually or via a `ModelDef` object's `createSaveStatement` and `createDeleteStatement` methods.

## Queries

Querying data out of the database is also very straightforward.  Each model object has
a set of static methods that can be used to query the database.

```swift
let things = Thing.allInstances() //Returns Array<Thing> that holds every instance of `Thing`

// Where clauses
let thing = Thing.firstInstanceWhere("tid = ?", "tid1") //Returns a Thing?
let someThings = Thing.instancesWhere("tid in (?, ?)", "tid1", "tid2") //Return Array<Thing> for each `Thing` that matches the where clause
```
