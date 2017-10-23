CREATE TABLE "Thing" (
  "localId" TEXT PRIMARY KEY,
  "tid" TEXT,
  "name" TEXT
);

CREATE UNIQUE INDEX "main"."INDEX_tid" ON Thing ("tid");

CREATE TABLE "Animal" (
  "aid" TEXT PRIMARY KEY,
  "name" TEXT,
  "living" INTEGER,
  "lastUpdated" REAL,
  "ids" BLOB,
  "props" BLOB
);

CREATE TABLE "Tree" (
  "localId" TEXT PRIMARY KEY,
  "name" TEXT,
  "status" INTEGER
);
