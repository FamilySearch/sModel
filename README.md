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

sModel will read data out of your database and map it into your model object. For this to
work, you simply subclass `BaseModel` and adopt the `ModelDef` protocol. Here's an example
domain object to match our db schema definition above.

```swift
class Thing: BaseModel {
  var tid = ""
  var name: String? = nil

  static let sqlTableName = "Thing"
  static let columns = [
    ColumnMeta(name: "tid", type: .text, constraint: .primary),
    ColumnMeta(name: "name", type: .text)
  ]
}

extension Thing: ModelDef {
  typealias ModelType = Thing
}
```

## Inserts/Updates

Inserting an object into the database is as simple as creating an instance, populating
it with data, and calling `save`.

```swift
let thing = Thing()
thing.tid = "tid1"
thing.name = "thing 1"
thing.save()
```

To update an existing object, just modify it's properties and call `save`.

## Queries

Querying data out of the database is also very straightforward.  Each model object has
a set of class methods that can be used to query the database.

```swift
let things = Thing.allInstances() //Returns Array<Thing> that holds every instance of `Thing`

// Where clauses
let thing = Thing.firstInstanceWhere("tid = ?", "tid1") //Returns a Thing?
let someThings = Thing.instancesWhere("tid in (?, ?)", "tid1", "tid2") //Return Array<Thing> for each `Thing` that matches the where clause
```
