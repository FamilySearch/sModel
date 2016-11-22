CREATE TABLE "Thing" (
  "tid" TEXT PRIMARY KEY,
  "name" TEXT
);

CREATE TABLE "Animal" (
  "aid" TEXT PRIMARY KEY,
  "name" TEXT,
  "living" INTEGER,
  "lastUpdated" REAL,
  "ids" BLOB,
  "props" BLOB
);