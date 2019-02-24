ALTER TABLE Person ADD active INTEGER;

CREATE TABLE "Message" (
  "localId" TEXT PRIMARY KEY,
  "messageId" TEXT,
  "content" TEXT,
  "createdOn" REAL,
  "ownerPersonId" TEXT,
  "syncStatus" INTEGER,
  "syncInFlightStatus" INTEGER
);
CREATE UNIQUE INDEX "main"."INDEX_messageId" ON Message ("messageId");
