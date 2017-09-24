CREATE TABLE "Place" (
  "pid" TEXT PRIMARY KEY,
  "name" TEXT
);

ALTER TABLE Thing ADD other INTEGER;
ALTER TABLE Thing ADD otherDouble REAL;

INSERT INTO Thing (localId, tid, name, other, otherDouble) VALUES ("localId", "tid1", "thing1", 10, 10.1234);
