//
//  DBLoadTestDefs.swift
//  sModelTests
//
//  Created by Stephen Lynn on 5/13/20.
//  Copyright © 2020 FamilySearch. All rights reserved.
//

import Foundation
import sModel

struct DBLoadTestDefs: DBDef {
  static let namespace = "DBLoadTestDefs"
  static let defs: [String] = [
    """
    CREATE TABLE "Artifact_Associations" (
      "artifact1LocalId" TEXT,
      "artifact2LocalId" TEXT,
      "deleted" INTEGER DEFAULT 0
    );

    CREATE TABLE "DataHint" (
      "localId" TEXT PRIMARY KEY,
      "pid" TEXT,
      "categoryRaw" TEXT,
      "typeRaw" TEXT,
      "contextRaw" TEXT,
      "canBeDismissed" INTEGER NOT NULL DEFAULT 0,
      "entityId" TEXT,
      "contextId" TEXT,
      "sortKey" INTEGER
    );

    CREATE TABLE "FSArtifact" (
      "localId" TEXT,
      "serverId" TEXT,
      "typeRaw" INTEGER NOT NULL,
      "url" TEXT,
      "thumbUrl" TEXT,
      "desc" TEXT,
      "title" TEXT,
      "mimeType" TEXT,
      "restricted" INTEGER NOT NULL,
      "editableByCaller" INTEGER NOT NULL,
      "category" TEXT,
      "contentCategory" TEXT,
      "uploadedOn" REAL NOT NULL,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "syncInFlightStatus" INTEGER NOT NULL,
      "syncStatus" INTEGER NOT NULL,
      "duration" INTEGER NOT NULL DEFAULT 0,
      "height" INTEGER NOT NULL DEFAULT 0,
      "width" INTEGER NOT NULL DEFAULT 0,
      "size" INTEGER NOT NULL DEFAULT 0,
      "fullText" TEXT,
      "artifactPatronId" TEXT DEFAULT NULL,
      "deepZoomLiteUrl" TEXT DEFAULT NULL,
      "portraitPhotoTagLocalId" TEXT,
      PRIMARY KEY("localId")
    );

    CREATE TABLE "FSContributor" (
      "localId" TEXT NOT NULL,
      "key" TEXT,
      "contributorId" TEXT,
      "artifactPatronId" TEXT,
      "name" TEXT,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "syncInFlightStatus" INTEGER NOT NULL,
      "syncStatus" INTEGER NOT NULL,
      "email" STRING DEFAULT '',
      "phoneNumber" STRING DEFAULT '',
      "cisUserId" STRING DEFAULT '',
      PRIMARY KEY("localId")
    );

    CREATE TABLE "FSConversation" (
      "localId" TEXT PRIMARY KEY,
      "serverId" TEXT,
      "about" TEXT,
      "aboutUrl" TEXT,
      "lastModifiedTime" REAL NOT NULL,
      "msgCount" INTEGER NOT NULL,
      "unreadMsgCount" INTEGER NOT NULL,
      "subject" TEXT,
      "userConversationState" TEXT,
      "participantIds" BLOB,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "syncInFlightStatus" INTEGER NOT NULL,
      "syncStatus" INTEGER NOT NULL
    );

    CREATE TABLE "FSCouple" (
      "localId" TEXT PRIMARY KEY,
      "person1Pid" TEXT,
      "person2Pid" TEXT,
      "relationshipId" TEXT,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "syncInFlightStatus" INTEGER NOT NULL,
      "syncStatus" INTEGER NOT NULL,
      "sortKey" INTEGER NOT NULL DEFAULT 2147483647
    );

    CREATE TABLE "FSDescendants" (
      "localId" text,
      "descendantPids" text,
      "pid" text,
      "cacheHash" TEXT,
      "lastFetchDate" real NOT NULL,
      "syncInFlightStatus" integer NOT NULL,
      "syncStatus" integer NOT NULL,
      PRIMARY KEY("localId")
    );

    CREATE TABLE "FSFOR" (
      "localId" TEXT PRIMARY KEY,
      "id" TEXT,
      "createdOn" REAL NOT NULL,
      "path" TEXT,
      "title" TEXT
    );

    CREATE TABLE "FSFact" (
      "localId" TEXT,
      "factId" TEXT,
      "ownerEntityId" TEXT,
      "nameForms" blob,
      "date" blob,
      "place" blob,
      "type" integer NOT NULL,
      "serverType" text,
      "value" TEXT,
      "contributorId" text,
      "lastModified" REAL NOT NULL DEFAULT 0,
      "changeMessage" TEXT,
      "sortKey" INTEGER NOT NULL DEFAULT 2147483647,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "syncStatus" INTEGER NOT NULL,
      "syncInFlightStatus" INTEGER NOT NULL,
      PRIMARY KEY("localId")
    );

    CREATE TABLE "FSHintList" (
      "localId" TEXT PRIMARY KEY,
      "pid" TEXT,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "syncInFlightStatus" INTEGER NOT NULL,
      "syncStatus" INTEGER NOT NULL
    );

    CREATE TABLE "FSHistoryItem" (
      "localId" TEXT,
      "sequenceNumber" INTEGER NOT NULL,
      "pid" TEXT,
      "displayName" TEXT,
      "lifespan" TEXT,
      "genderRaw" INTEGER NOT NULL DEFAULT 0,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "syncInFlightStatus" INTEGER NOT NULL,
      "syncStatus" INTEGER NOT NULL,
      PRIMARY KEY("localId")
    );

    CREATE TABLE "FSHistoryList" (
      "localId" TEXT PRIMARY KEY,
      "pid" TEXT,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "syncInFlightStatus" INTEGER NOT NULL,
      "syncStatus" INTEGER NOT NULL
    );

    CREATE TABLE "FSMessage" (
      "localId" TEXT PRIMARY KEY,
      "serverId" TEXT,
      "conversationId" TEXT,
      "authorId" TEXT,
      "body" TEXT,
      "created" REAL NOT NULL,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "syncInFlightStatus" INTEGER NOT NULL,
      "syncStatus" INTEGER NOT NULL
    );

    CREATE TABLE "FSMyArtifacts" (
      "localId" TEXT PRIMARY KEY,
      "listType" INTEGER NOT NULL,
      "cacheHash" TEXT,
      "cisId" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "syncInFlightStatus" INTEGER NOT NULL,
      "syncStatus" INTEGER NOT NULL
    );

    CREATE TABLE "FSMyTaggedPersons" (
      "localId" TEXT PRIMARY KEY,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "syncInFlightStatus" INTEGER NOT NULL,
      "syncStatus" INTEGER NOT NULL
    );

    CREATE TABLE "FSParentChild" (
      "localId" TEXT,
      "relationshipId" TEXT,
      "childId" TEXT,
      "fatherId" TEXT,
      "motherId" TEXT,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "syncInFlightStatus" INTEGER NOT NULL,
      "syncStatus" INTEGER NOT NULL,
      "parentSortKey" INTEGER NOT NULL DEFAULT 0,
      "childSortKey" INTEGER NOT NULL DEFAULT 0,
      PRIMARY KEY("localId")
    );

    CREATE TABLE "FSPedigree" (
      "localId" TEXT PRIMARY KEY,
      "ancestorPids" TEXT,
      "pid" TEXT,
      "preferredSpousePid" TEXT,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "syncInFlightStatus" INTEGER NOT NULL,
      "syncStatus" INTEGER NOT NULL
    );

    CREATE TABLE "FSPersonArtifacts" (
      "localId" TEXT PRIMARY KEY,
      "pid" TEXT,
      "listType" INTEGER NOT NULL,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "syncInFlightStatus" INTEGER NOT NULL,
      "syncStatus" INTEGER NOT NULL
    );

    CREATE TABLE "FSPersonNote" (
      "localId" TEXT PRIMARY KEY,
      "serverId" TEXT,
      "pid" TEXT,
      "subject" TEXT,
      "text" TEXT,
      "contributorId" text,
      "lastModified" INTEGER NOT NULL DEFAULT 0,
      "changeMessage" TEXT,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "syncInFlightStatus" INTEGER NOT NULL,
      "syncStatus" INTEGER NOT NULL
    );

    CREATE TABLE "FSPersonNoteList" (
      "localId" TEXT PRIMARY KEY,
      "pid" TEXT,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "syncInFlightStatus" INTEGER NOT NULL,
      "syncStatus" INTEGER NOT NULL
    );

    CREATE TABLE "FSPersonPotentialPortrait" (
      "photoTagLocalId" TEXT PRIMARY KEY NOT NULL,
      "personLocalId" TEXT NOT NULL
    );

    CREATE TABLE "FSPersonVitals" (
      "localId" TEXT,
      "displayName" TEXT,
      "fullName" TEXT,
      "genderRaw" INTEGER,
      "givenName" TEXT,
      "lifespan" TEXT,
      "living" INTEGER NOT NULL DEFAULT 0,
      "pid" TEXT NOT NULL,
      "surName" TEXT,
      "preferredSpousePid" TEXT,
      "preferredParentsRelationshipId" TEXT,
      "sortKey" INTEGER NOT NULL DEFAULT 999999999,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "portraitArtifactLocalId" TEXT,
      "suffix" TEXT,
      "syncInFlightStatus" INTEGER NOT NULL,
      "syncStatus" INTEGER NOT NULL,
      PRIMARY KEY("localId")
    );

    CREATE TABLE "FSPersona" (
      "localId" TEXT PRIMARY KEY,
      "serverId" TEXT,
      "name" TEXT,
      "treePersonIds" BLOB,
      "photoTagServerId" TEXT DEFAULT NULL,
      "detachReason" TEXT DEFAULT NULL,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "syncInFlightStatus" INTEGER NOT NULL,
      "syncStatus" INTEGER NOT NULL
    );

    CREATE TABLE "FSPhotoTag" (
      "localId" TEXT PRIMARY KEY,
      "artifactLocalId" TEXT,
      "artifactServerId" TEXT,
      "deletable" INTEGER NOT NULL DEFAULT 0,
      "editable" INTEGER NOT NULL DEFAULT 0,
      "height" REAL NOT NULL DEFAULT 0,
      "serverId" TEXT,
      "softTag" INTEGER NOT NULL DEFAULT 0,
      "taggedPersonLocalId" TEXT,
      "taggedPersonServerId" TEXT,
      "title" TEXT,
      "width" REAL NOT NULL DEFAULT 0,
      "x" REAL NOT NULL DEFAULT 0,
      "y" REAL NOT NULL DEFAULT 0,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "syncInFlightStatus" INTEGER NOT NULL,
      "syncStatus" INTEGER NOT NULL,
      "personaLocalId" STRING DEFAULT NULL,
      "personaServerId" STRING DEFAULT NULL
    );

    CREATE TABLE "FSRecordHint" (
      "localId" TEXT PRIMARY KEY,
      "serverId" TEXT,
      "matchedId" TEXT,
      "sourceLinkUrl" TEXT,
      "pid" TEXT,
      "title" TEXT,
      "collectionType" TEXT,
      "personName" TEXT,
      "score" REAL NOT NULL DEFAULT 0,
      "published" REAL NOT NULL DEFAULT 0,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "syncInFlightStatus" INTEGER NOT NULL,
      "syncStatus" INTEGER NOT NULL
    );

    CREATE TABLE "FSRelationships" (
      "localId" TEXT PRIMARY KEY,
      "pid" TEXT,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "syncInFlightStatus" INTEGER NOT NULL,
      "syncStatus" INTEGER NOT NULL
    );

    CREATE TABLE "FSReservations" (
      "localId" TEXT PRIMARY KEY,
      "personReservationIds" BLOB,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "syncInFlightStatus" INTEGER NOT NULL,
      "syncStatus" INTEGER NOT NULL
    );

    CREATE TABLE "FSScopeOfInterest" (
      "localId" TEXT PRIMARY KEY,
      "pids" BLOB,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "syncInFlightStatus" INTEGER NOT NULL,
      "syncStatus" INTEGER NOT NULL
    );

    CREATE TABLE "FSSource" (
      "localId" TEXT PRIMARY KEY,
      "artifactLocalId" TEXT,
      "artifactServerId" TEXT,
      "serverId" TEXT,
      "title" TEXT,
      "url" TEXT,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "syncInFlightStatus" INTEGER NOT NULL,
      "syncStatus" INTEGER NOT NULL,
      "notes" TEXT DEFAULT '',
      "citation" TEXT DEFAULT '',
      "contributorCisId" TEXT DEFAULT '',
      "modifiedTimestamp" INTEGER NOT NULL DEFAULT 0,
      "resourceType" TEXT '',
      "changeMessage" TEXT ''
    );

    CREATE TABLE "FSSourceReference" (
      "localId" TEXT PRIMARY KEY,
      "pid" TEXT,
      "sourceLocalId" TEXT,
      "sourceReferenceServerId" TEXT,
      "changeMessage" TEXT,
      "contributorId" TEXT,
      "modifiedTimestamp" INTEGER NOT NULL DEFAULT 0,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "syncInFlightStatus" INTEGER NOT NULL,
      "syncStatus" INTEGER NOT NULL
    );

    CREATE TABLE "FSSourceReferenceList" (
      "localId" TEXT PRIMARY KEY,
      "pid" TEXT,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "syncInFlightStatus" INTEGER NOT NULL,
      "syncStatus" INTEGER NOT NULL
    );

    CREATE TABLE "FSTaggedPerson" (
      "localId" TEXT PRIMARY KEY,
      "name" TEXT,
      "pid" TEXT,
      "serverId" TEXT,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "portraitArtifactLocalId" TEXT,
      "syncInFlightStatus" INTEGER NOT NULL,
      "syncStatus" INTEGER NOT NULL,
      "myTaggedPersonsLocalId" TEXT,
      "didLinkToPidOnServer" INTEGER NOT NULL DEFAULT 0
    );

    CREATE TABLE "FSUser" (
      "localId" TEXT,
      "cisId" TEXT,
      "contactName" TEXT,
      "email" TEXT,
      "fullName" TEXT,
      "isMember" INTEGER NOT NULL DEFAULT 1,
      "pid" TEXT,
      "userId" TEXT,
      "username" TEXT,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "syncInFlightStatus" INTEGER NOT NULL,
      "syncStatus" INTEGER NOT NULL, helperPin STRING DEFAULT '', hasHelperPermission INTEGER NOT NULL DEFAULT 0,
      PRIMARY KEY("localId")
    );

    CREATE TABLE "FSWatch" (
      "localId" TEXT PRIMARY KEY,
      "pid" TEXT,
      "resourceId" TEXT,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "syncInFlightStatus" INTEGER NOT NULL,
      "syncStatus" INTEGER NOT NULL
    );

    CREATE TABLE "List_Artifact" (
      "listLocalId" TEXT,
      "listType" INTEGER,
      "artifactLocalId" TEXT,
      "artifactType" INTEGER
    );

    CREATE TABLE "Ordinance" (
      "localId" TEXT,
      "assignedToTemple" INTEGER NOT NULL,
      "bornInCovenant" INTEGER NOT NULL,
      "canPrint" INTEGER NOT NULL,
      "completedDate" TEXT,
      "completedPlace" TEXT,
      "fatherId" TEXT,
      "fatherName" TEXT,
      "motherId" TEXT,
      "motherName" TEXT,
      "reserve" INTEGER NOT NULL,
      "spouseId" TEXT,
      "status" INTEGER NOT NULL,
      "type" INTEGER NOT NULL,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "syncInFlightStatus" INTEGER NOT NULL,
      "syncStatus" INTEGER NOT NULL,
      "personReservationPid" TEXT,
      "whyNotQualifying" TEXT DEFAULT NULL,
      "ownerName" TEXT DEFAULT '',
      "reservedDate" TEXT DEFAULT '',
      "comparableReservedDate" TEXT DEFAULT '',
      "requiresPermission" INTEGER NOT NULL,
      "canAssign" INTEGER NOT NULL DEFAULT 0,
      "canTransfer" INTEGER NOT NULL DEFAULT 0,
      "canUnreserve" INTEGER NOT NULL DEFAULT 0,
      "shareBatchId" STRING DEFAULT '',
      "shareComparableExpireDate" STRING DEFAULT '',
      "shareShareExpireDate" STRING DEFAULT '',
      "shareReceiveUrl" STRING DEFAULT '',
      PRIMARY KEY("localId")
    );

    CREATE TABLE "PersonReservation" (
      "localId" TEXT,
      "displayName" TEXT,
      "gender" TEXT,
      "givenName" TEXT,
      "lifespan" TEXT,
      "pid" TEXT,
      "surName" TEXT,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "syncInFlightStatus" INTEGER NOT NULL,
      "syncStatus" INTEGER NOT NULL,
      "hasDuplicate" INTEGER NOT NULL DEFAULT 0,
      PRIMARY KEY("localId")
    );

    CREATE UNIQUE INDEX "INDEX_Artifact_Associations_unique" ON Artifact_Associations ("artifact1LocalId", "artifact2LocalId");
    CREATE UNIQUE INDEX "INDEX_List_Artifact_listId_artifactId" ON List_Artifact ("listLocalId", "artifactLocalId");

    CREATE UNIQUE INDEX "main"."INDEX_artifact_server" ON FSArtifact ("serverId");
    CREATE UNIQUE INDEX "main"."INDEX_conversation_server" ON FSConversation ("serverId");
    CREATE UNIQUE INDEX "main"."INDEX_contributor_server" ON FSContributor ("contributorId");
    CREATE UNIQUE INDEX "main"."INDEX_couple_server" ON FSCouple ("relationshipId");
    CREATE UNIQUE INDEX "main"."INDEX_descendants_server" ON FSDescendants ("pid");
    CREATE UNIQUE INDEX "main"."INDEX_fact_server" ON FSFact ("factId", "ownerEntityId");
    CREATE UNIQUE INDEX "main"."INDEX_hintList_server" ON FSHintList ("pid");
    CREATE UNIQUE INDEX "main"."INDEX_message_server" ON FSMessage ("serverId");
    CREATE UNIQUE INDEX "main"."INDEX_parentChild_server" ON FSParentChild ("relationshipId");
    CREATE UNIQUE INDEX "main"."INDEX_pedigree_server" ON FSPedigree ("pid", "preferredSpousePid");
    CREATE UNIQUE INDEX "main"."INDEX_persona_server" ON FSPersona ("serverId");
    CREATE UNIQUE INDEX "main"."INDEX_personArtifacts_server" ON FSPersonArtifacts ("pid");
    CREATE UNIQUE INDEX "main"."INDEX_note_server" ON FSPersonNote ("serverId");
    CREATE UNIQUE INDEX "main"."INDEX_noteList_server" ON FSPersonNoteList ("pid");
    CREATE UNIQUE INDEX "main"."INDEX_person_server" ON FSPersonVitals ("pid");
    CREATE UNIQUE INDEX "main"."INDEX_photoTag_server" ON FSPhotoTag ("serverId");
    CREATE UNIQUE INDEX "main"."INDEX_recordHint_server" ON FSRecordHint ("serverId");
    CREATE UNIQUE INDEX "main"."INDEX_relationship_server" ON FSRelationships ("pid");
    CREATE UNIQUE INDEX "main"."INDEX_source_server" ON FSSource ("serverId");
    CREATE UNIQUE INDEX "main"."INDEX_sourceReference_server" ON FSSourceReference ("sourceReferenceServerId");
    CREATE UNIQUE INDEX "main"."INDEX_sourceReferenceList_server" ON FSSourceReferenceList ("pid");
    CREATE UNIQUE INDEX "main"."INDEX_taggedPerson_server" ON FSTaggedPerson ("serverId");
    CREATE UNIQUE INDEX "main"."INDEX_watch_server" ON FSWatch ("pid");
    CREATE UNIQUE INDEX "main"."INDEX_ordinance_server" ON Ordinance ("type", "personReservationPid");
    CREATE UNIQUE INDEX "main"."INDEX_personReservation_server" ON PersonReservation ("pid");
    """,

    """
    ALTER TABLE "main"."FSUser" RENAME TO "_FSUser_old_20170208";

    CREATE TABLE "main"."FSUser" (
    "localId" TEXT,
    "cisId" TEXT,
    "contactName" TEXT,
    "email" TEXT,
    "fullName" TEXT,
    "isMember" INTEGER NOT NULL DEFAULT 1,
    "pid" TEXT,
    "userId" TEXT,
    "username" TEXT,
    "cacheHash" TEXT,
    "lastFetchDate" REAL NOT NULL,
    "syncInFlightStatus" INTEGER NOT NULL,
    "syncStatus" INTEGER NOT NULL,
    "helperPin" TEXT DEFAULT '',
    "hasHelperPermission" INTEGER NOT NULL DEFAULT 0,
    PRIMARY KEY("localId")
    );

    INSERT INTO "main"."FSUser" ("localId", "cisId", "contactName", "email", "fullName", "isMember", "pid", "userId", "username", "cacheHash", "lastFetchDate", "syncInFlightStatus", "syncStatus", "hasHelperPermission" ) SELECT "localId", "cisId", "contactName", "email", "fullName", "isMember", "pid", "userId", "username", "cacheHash", "lastFetchDate", "syncInFlightStatus", "syncStatus", "hasHelperPermission" FROM "main"."_FSUser_old_20170208";

    DROP TABLE _FSUser_old_20170208;
    """,

    """
    ALTER TABLE FSPhotoTag ADD taggedPersonPid STRING DEFAULT '';
    """,

    """
    CREATE TABLE "PersonTasksList" (
    "localId" TEXT PRIMARY KEY,
    "listKeyRaw" TEXT NOT NULL,
    "numGens" INTEGER,
    "cacheHash" TEXT,
    "lastFetchDate" REAL NOT NULL,
    "syncInFlightStatus" INTEGER NOT NULL,
    "syncStatus" INTEGER NOT NULL
    );

    CREATE TABLE "PersonTasks" (
    "localId" TEXT PRIMARY KEY,
    "listKeyRaw" TEXT NOT NULL,
    "pid" TEXT NOT NULL,
    "sortKey" INTEGER NOT NULL,
    "hasHints" INTEGER NOT NULL,
    "templeStatusRaw" INTEGER NOT NULL,
    "displayName" TEXT NOT NULL,
    "genderRaw" INTEGER NOT NULL,
    "lifespan" TEXT,
    "living" INTEGER NOT NULL,
    "cacheHash" TEXT,
    "lastFetchDate" REAL NOT NULL,
    "syncInFlightStatus" INTEGER NOT NULL,
    "syncStatus" INTEGER NOT NULL
    );

    CREATE UNIQUE INDEX "main"."INDEX_personTasksList_listKey" ON PersonTasksList ("listKeyRaw");
    CREATE UNIQUE INDEX "main"."INDEX_personTasks_listKey_pid" ON PersonTasks ("listKeyRaw", "pid");
    """,

    """
    ALTER TABLE FSFact ADD placeId text DEFAULT NULL;

    CREATE TABLE "Place" (
      "id" text NOT NULL,
      "latitude" real,
      "longitude" real,
      "name" text NOT NULL,
      PRIMARY KEY("id")
    );
    """,

    """
    ALTER TABLE FSSourceReference ADD sortKey STRING NOT NULL DEFAULT '';
    """,

    """
    DROP INDEX "INDEX_ordinance_server";
    CREATE UNIQUE INDEX "INDEX_ordinance_server" ON Ordinance ("type", "personReservationPid", "fatherId", "motherId", "spouseId");
    """,

    """
    ALTER TABLE FSArtifact ADD serverHash TEXT DEFAULT '';
    """,

    """
    CREATE TABLE "Album" (
    "localId" TEXT PRIMARY KEY,
    "serverId" TEXT,
    "listType" INTEGER NOT NULL,
    "albumName" TEXT,
    "albumDescription" TEXT,
    "contributorPatronId" INTEGER NOT NULL,
    "uploaderId" INTEGER NOT NULL,
    "creationDateTime" INTEGER NOT NULL,
    "restrictionState" TEXT NOT NULL,
    "artifactCount" INTEGER NOT NULL,
    "thumbUrl" TEXT,
    "thumbSquareUrl" TEXT,
    "thumbIconUrl" TEXT,
    "seoIndexable" INTEGER NOT NULL,
    "favorite" INTEGER NOT NULL,
    "editableByCaller" INTEGER NOT NULL,
    "cacheHash" TEXT,
    "lastFetchDate" REAL NOT NULL,
    "syncInFlightStatus" INTEGER NOT NULL,
    "syncStatus" INTEGER NOT NULL
    );

    CREATE UNIQUE INDEX "main"."INDEX_album_server" ON Album ("serverId");

    CREATE TABLE "MyAlbumsList" (
    "localId" TEXT PRIMARY KEY,
    "cacheHash" TEXT,
    "lastFetchDate" REAL NOT NULL,
    "syncInFlightStatus" INTEGER NOT NULL,
    "syncStatus" INTEGER NOT NULL
    );

    ALTER TABLE FSArtifact ADD archived INTEGER NOT NULL DEFAULT 0;
    """,

    """
    DROP TABLE FSScopeOfInterest;

    CREATE TABLE "ScopeAncestor" (
    "localId" TEXT PRIMARY KEY,
    "scopeTypeRaw" TEXT NOT NULL,
    "pid" TEXT NOT NULL,
    "cacheHash" TEXT,
    "lastFetchDate" REAL NOT NULL,
    "syncInFlightStatus" INTEGER NOT NULL,
    "syncStatus" INTEGER NOT NULL
    );

    CREATE UNIQUE INDEX "main"."INDEX_ScopeAncestor_scopeTypeRaw_pid" ON ScopeAncestor ("scopeTypeRaw", "pid");
    """,

    """
    CREATE TABLE "PedigreePreferences" (
    "localId" TEXT PRIMARY KEY,
    "pid" TEXT NOT NULL,
    "preferredCoupleId" TEXT,
    "preferredParentChildId" TEXT,
    "preferredCoparentParentChildId" TEXT,
    "cacheHash" TEXT,
    "lastFetchDate" REAL NOT NULL,
    "syncInFlightStatus" INTEGER NOT NULL,
    "syncStatus" INTEGER NOT NULL
    );

    CREATE UNIQUE INDEX "main"."INDEX_PedigreePreferences_pid" ON PedigreePreferences ("pid");
    """,

    """
    /* */
    /* Update tables to not use "raw" in names of enum property stores and remove unused columns */
    /* */

    /* Album */
    ALTER TABLE "main"."Album" RENAME TO "_Album_old_20171023";
    DROP INDEX "main"."INDEX_album_server";

    CREATE TABLE "main"."Album" (
      "localId" TEXT,
      "serverId" TEXT,
      "listType" INTEGER NOT NULL,
      "albumName" TEXT,
      "albumDescription" TEXT,
      "contributorPatronId" INTEGER NOT NULL,
      "uploaderId" INTEGER NOT NULL,
      "creationDateTime" INTEGER NOT NULL,
      "restrictionState" TEXT NOT NULL,
      "artifactCount" INTEGER NOT NULL,
      "thumbUrl" TEXT,
      "thumbSquareUrl" TEXT,
      "thumbIconUrl" TEXT,
      "seoIndexable" INTEGER NOT NULL,
      "favorite" INTEGER NOT NULL,
      "editableByCaller" INTEGER NOT NULL,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      PRIMARY KEY("localId")
    );

    INSERT INTO "main"."Album" ("localId", "serverId", "listType", "albumName", "albumDescription", "contributorPatronId", "uploaderId", "creationDateTime", "restrictionState", "artifactCount", "thumbUrl", "thumbSquareUrl", "thumbIconUrl", "seoIndexable", "favorite", "editableByCaller", "cacheHash", "lastFetchDate") SELECT "localId", "serverId", "listType", "albumName", "albumDescription", "contributorPatronId", "uploaderId", "creationDateTime", "restrictionState", "artifactCount", "thumbUrl", "thumbSquareUrl", "thumbIconUrl", "seoIndexable", "favorite", "editableByCaller", "cacheHash", "lastFetchDate" FROM "main"."_Album_old_20171023";
    CREATE UNIQUE INDEX "main"."INDEX_album_server" ON Album ("serverId" ASC);
    DROP TABLE _Album_old_20171023;


    /* Contributor */
    ALTER TABLE "main"."FSContributor" RENAME TO "_FSContributor_old_20171023";
    DROP INDEX "main"."INDEX_contributor_server";

    CREATE TABLE "main"."FSContributor" (
      "localId" TEXT NOT NULL,
      "key" TEXT,
      "contributorId" TEXT,
      "artifactPatronId" TEXT,
      "name" TEXT,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "email" STRING DEFAULT '',
      "phoneNumber" STRING DEFAULT '',
      "cisUserId" STRING DEFAULT '',
      PRIMARY KEY("localId")
    );

    INSERT INTO "main"."FSContributor" ("localId", "key", "contributorId", "artifactPatronId", "name", "cacheHash", "lastFetchDate", "email", "phoneNumber", "cisUserId") SELECT "localId", "key", "contributorId", "artifactPatronId", "name", "cacheHash", "lastFetchDate", "email", "phoneNumber", "cisUserId" FROM "main"."_FSContributor_old_20171023";
    CREATE UNIQUE INDEX "main"."INDEX_contributor_server" ON FSContributor ("contributorId" ASC);
    DROP TABLE _FSContributor_old_20171023;


    /* Couple */
    ALTER TABLE "main"."FSCouple" RENAME TO "_FSCouple_old_20171023";
    DROP INDEX "main"."INDEX_couple_server";

    CREATE TABLE "main"."FSCouple" (
      "localId" TEXT,
      "person1Pid" TEXT,
      "person2Pid" TEXT,
      "relationshipId" TEXT,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "sortKey" INTEGER NOT NULL DEFAULT 2147483647,
      PRIMARY KEY("localId")
    );

    INSERT INTO "main"."FSCouple" ("localId", "person1Pid", "person2Pid", "relationshipId", "cacheHash", "lastFetchDate", "sortKey") SELECT "localId", "person1Pid", "person2Pid", "relationshipId", "cacheHash", "lastFetchDate", "sortKey" FROM "main"."_FSCouple_old_20171023";
    CREATE UNIQUE INDEX "main"."INDEX_couple_server" ON FSCouple ("relationshipId" ASC);
    DROP TABLE _FSCouple_old_20171023;

    /* Descendants */
    ALTER TABLE "main"."FSDescendants" RENAME TO "_FSDescendants_old_20171023";
    DROP INDEX "main"."INDEX_descendants_server";

    CREATE TABLE "main"."FSDescendants" (
      "localId" text,
      "descendantPids" text,
      "pid" text,
      "cacheHash" TEXT,
      "lastFetchDate" real NOT NULL,
      PRIMARY KEY("localId")
    );

    INSERT INTO "main"."FSDescendants" ("localId", "descendantPids", "pid", "cacheHash", "lastFetchDate") SELECT "localId", "descendantPids", "pid", "cacheHash", "lastFetchDate" FROM "main"."_FSDescendants_old_20171023";
    CREATE UNIQUE INDEX "main"."INDEX_descendants_server" ON FSDescendants ("pid" ASC);
    DROP TABLE _FSDescendants_old_20171023;


    /* DataHint */
    ALTER TABLE "main"."DataHint" RENAME TO "_DataHint_old_20171023";

    CREATE TABLE "main"."DataHint" (
      "localId" TEXT,
      "pid" TEXT,
      "category" TEXT,
      "type" TEXT,
      "contextRaw" TEXT,
      "canBeDismissed" INTEGER NOT NULL DEFAULT 0,
      "entityId" TEXT,
      "contextId" TEXT,
      "sortKey" INTEGER,
      PRIMARY KEY("localId")
    );

    INSERT INTO "main"."DataHint" ("localId", "pid", "category", "type", "contextRaw", "canBeDismissed", "entityId", "contextId", "sortKey") SELECT "localId", "pid", "categoryRaw", "typeRaw", "contextRaw", "canBeDismissed", "entityId", "contextId", "sortKey" FROM "main"."_DataHint_old_20171023";
    DROP TABLE _DataHint_old_20171023;


    /* Artifact */
    ALTER TABLE "main"."FSArtifact" RENAME TO "_FSArtifact_old_20171023";
    DROP INDEX "main"."INDEX_artifact_server";

    CREATE TABLE "main"."FSArtifact" (
      "localId" TEXT,
      "serverId" TEXT,
      "type" INTEGER NOT NULL DEFAULT 6,
      "url" TEXT,
      "thumbUrl" TEXT,
      "desc" TEXT,
      "title" TEXT,
      "mimeType" TEXT,
      "restricted" INTEGER NOT NULL,
      "editableByCaller" INTEGER NOT NULL,
      "category" TEXT,
      "contentCategory" TEXT,
      "uploadedOn" REAL NOT NULL,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "syncInFlightStatus" INTEGER NOT NULL,
      "syncStatus" INTEGER NOT NULL,
      "duration" INTEGER NOT NULL DEFAULT 0,
      "height" INTEGER NOT NULL DEFAULT 0,
      "width" INTEGER NOT NULL DEFAULT 0,
      "size" INTEGER NOT NULL DEFAULT 0,
      "fullText" TEXT,
      "artifactPatronId" TEXT DEFAULT NULL,
      "deepZoomLiteUrl" TEXT DEFAULT NULL,
      "portraitPhotoTagLocalId" TEXT,
      "serverHash" TEXT DEFAULT '',
      "archived" INTEGER NOT NULL DEFAULT 0,
      PRIMARY KEY("localId")
    );

    INSERT INTO "main"."FSArtifact" ("localId", "serverId", "type", "url", "thumbUrl", "desc", "title", "mimeType", "restricted", "editableByCaller", "category", "contentCategory", "uploadedOn", "cacheHash", "lastFetchDate", "syncInFlightStatus", "syncStatus", "duration", "height", "width", "size", "fullText", "artifactPatronId", "deepZoomLiteUrl", "portraitPhotoTagLocalId", "serverHash", "archived") SELECT "localId", "serverId", "typeRaw", "url", "thumbUrl", "desc", "title", "mimeType", "restricted", "editableByCaller", "category", "contentCategory", "uploadedOn", "cacheHash", "lastFetchDate", "syncInFlightStatus", "syncStatus", "duration", "height", "width", "size", "fullText", "artifactPatronId", "deepZoomLiteUrl", "portraitPhotoTagLocalId", "serverHash", "archived" FROM "main"."_FSArtifact_old_20171023";
    CREATE UNIQUE INDEX "main"."INDEX_artifact_server" ON FSArtifact ("serverId" ASC);
    DROP TABLE _FSArtifact_old_20171023;

    /* FSHistoryItem */
    ALTER TABLE "main"."FSHistoryItem" RENAME TO "_FSHistoryItem_old_20171023";

    CREATE TABLE "main"."FSHistoryItem" (
      "localId" TEXT,
      "sequenceNumber" INTEGER NOT NULL,
      "pid" TEXT,
      "displayName" TEXT,
      "lifespan" TEXT,
      "gender" INTEGER NOT NULL DEFAULT 0,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      PRIMARY KEY("localId")
    );

    INSERT INTO "main"."FSHistoryItem" ("localId", "sequenceNumber", "pid", "displayName", "lifespan", "gender", "cacheHash", "lastFetchDate") SELECT "localId", "sequenceNumber", "pid", "displayName", "lifespan", "genderRaw", "cacheHash", "lastFetchDate" FROM "main"."_FSHistoryItem_old_20171023";
    DROP TABLE _FSHistoryItem_old_20171023;

    /* Person */
    ALTER TABLE "main"."FSPersonVitals" RENAME TO "_FSPersonVitals_old_20171023";
    DROP INDEX "main"."INDEX_person_server";

    CREATE TABLE "main"."FSPersonVitals" (
      "localId" TEXT,
      "displayName" TEXT,
      "fullName" TEXT,
      "gender" INTEGER,
      "givenName" TEXT,
      "lifespan" TEXT,
      "living" INTEGER NOT NULL DEFAULT 0,
      "pid" TEXT NOT NULL,
      "surName" TEXT,
      "preferredSpousePid" TEXT,
      "preferredParentsRelationshipId" TEXT,
      "sortKey" INTEGER NOT NULL DEFAULT 999999999,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "portraitArtifactLocalId" TEXT,
      "suffix" TEXT,
      PRIMARY KEY("localId")
    );

    INSERT INTO "main"."FSPersonVitals" ("localId", "displayName", "fullName", "gender", "givenName", "lifespan", "living", "pid", "surName", "preferredSpousePid", "preferredParentsRelationshipId", "sortKey", "cacheHash", "lastFetchDate", "portraitArtifactLocalId", "suffix") SELECT "localId", "displayName", "fullName", "genderRaw", "givenName", "lifespan", "living", "pid", "surName", "preferredSpousePid", "preferredParentsRelationshipId", "sortKey", "cacheHash", "lastFetchDate", "portraitArtifactLocalId", "suffix" FROM "main"."_FSPersonVitals_old_20171023";
    CREATE UNIQUE INDEX "main"."INDEX_person_server" ON FSPersonVitals ("pid" ASC);
    DROP TABLE _FSPersonVitals_old_20171023;


    /* ScopeAncestor */
    ALTER TABLE "main"."ScopeAncestor" RENAME TO "_ScopeAncestor_old_20171023";
    DROP INDEX "main"."INDEX_ScopeAncestor_scopeTypeRaw_pid";

    CREATE TABLE "main"."ScopeAncestor" (
      "localId" TEXT,
      "scopeType" TEXT NOT NULL,
      "pid" TEXT NOT NULL,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      PRIMARY KEY("localId")
    );

    INSERT INTO "main"."ScopeAncestor" ("localId", "scopeType", "pid", "cacheHash", "lastFetchDate") SELECT "localId", "scopeTypeRaw", "pid", "cacheHash", "lastFetchDate" FROM "main"."_ScopeAncestor_old_20171023";
    CREATE UNIQUE INDEX "main"."INDEX_ScopeAncestor_scopeType_pid" ON ScopeAncestor ("scopeType" ASC, "pid" ASC);
    DROP TABLE _ScopeAncestor_old_20171023;

    /* Fact */
    ALTER TABLE "main"."FSFact" RENAME TO "_FSFact_old_20171023";
    DROP INDEX "main"."INDEX_fact_server";

    CREATE TABLE "main"."FSFact" (
      "localId" TEXT,
      "factId" TEXT,
      "ownerEntityId" TEXT,
      "nameData" blob,
      "dateData" blob,
      "placeData" blob,
      "type" integer NOT NULL,
      "serverType" text,
      "value" TEXT,
      "contributorId" text,
      "lastModified" REAL NOT NULL DEFAULT 0,
      "changeMessage" TEXT,
      "sortKey" INTEGER NOT NULL DEFAULT 2147483647,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "placeId" text DEFAULT NULL,
      PRIMARY KEY("localId")
    );

    INSERT INTO "main"."FSFact" ("localId", "factId", "ownerEntityId", "nameData", "dateData", "placeData", "type", "serverType", "value", "contributorId", "lastModified", "changeMessage", "sortKey", "cacheHash", "lastFetchDate", "placeId") SELECT "localId", "factId", "ownerEntityId", "nameForms", "date", "place", "type", "serverType", "value", "contributorId", "lastModified", "changeMessage", "sortKey", "cacheHash", "lastFetchDate", "placeId" FROM "main"."_FSFact_old_20171023";
    CREATE UNIQUE INDEX "main"."INDEX_fact_server" ON FSFact ("factId" ASC, "ownerEntityId" ASC);
    DROP TABLE _FSFact_old_20171023;


    /* HintList */
    ALTER TABLE "main"."FSHintList" RENAME TO "_FSHintList_old_20171023";
    DROP INDEX "main"."INDEX_hintList_server";

    CREATE TABLE "main"."FSHintList" (
      "localId" TEXT,
      "pid" TEXT,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      PRIMARY KEY("localId")
    );

    INSERT INTO "main"."FSHintList" ("localId", "pid", "cacheHash", "lastFetchDate") SELECT "localId", "pid", "cacheHash", "lastFetchDate" FROM "main"."_FSHintList_old_20171023";
    CREATE UNIQUE INDEX "main"."INDEX_hintList_server" ON FSHintList ("pid" ASC);
    DROP TABLE _FSHintList_old_20171023;


    /* HistoryItem */
    ALTER TABLE "main"."FSHistoryItem" RENAME TO "_FSHistoryItem_old_20171023";

    CREATE TABLE "main"."FSHistoryItem" (
      "localId" TEXT,
      "sequenceNumber" INTEGER NOT NULL,
      "pid" TEXT,
      "displayName" TEXT,
      "lifespan" TEXT,
      "gender" INTEGER NOT NULL DEFAULT 0,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      PRIMARY KEY("localId")
    );

    INSERT INTO "main"."FSHistoryItem" ("localId", "sequenceNumber", "pid", "displayName", "lifespan", "gender", "cacheHash", "lastFetchDate") SELECT "localId", "sequenceNumber", "pid", "displayName", "lifespan", "genderRaw", "cacheHash", "lastFetchDate" FROM "main"."_FSHistoryItem_old_20171023";
    DROP TABLE _FSHistoryItem_old_20171023;


    /* User */
    ALTER TABLE "main"."FSUser" RENAME TO "_FSUser_old_20171023";

    CREATE TABLE "main"."FSUser" (
      "localId" TEXT,
      "cisId" TEXT,
      "contactName" TEXT,
      "email" TEXT,
      "fullName" TEXT,
      "isMember" INTEGER NOT NULL DEFAULT 1,
      "pid" TEXT,
      "userId" TEXT,
      "username" TEXT,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "helperPin" TEXT DEFAULT '',
      "hasHelperPermission" INTEGER NOT NULL DEFAULT 0,
      PRIMARY KEY("localId")
    );

    INSERT INTO "main"."FSUser" ("localId", "cisId", "contactName", "email", "fullName", "isMember", "pid", "userId", "username", "cacheHash", "lastFetchDate", "helperPin", "hasHelperPermission") SELECT "localId", "cisId", "contactName", "email", "fullName", "isMember", "pid", "userId", "username", "cacheHash", "lastFetchDate", "helperPin", "hasHelperPermission" FROM "main"."_FSUser_old_20171023";
    DROP TABLE _FSUser_old_20171023;


    /* HistoryList */
    ALTER TABLE "main"."FSHistoryList" RENAME TO "_FSHistoryList_old_20171023";

    CREATE TABLE "main"."FSHistoryList" (
      "localId" TEXT,
      "pid" TEXT,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      PRIMARY KEY("localId")
    );

    INSERT INTO "main"."FSHistoryList" ("localId", "pid", "cacheHash", "lastFetchDate") SELECT "localId", "pid", "cacheHash", "lastFetchDate" FROM "main"."_FSHistoryList_old_20171023";
    DROP TABLE _FSHistoryList_old_20171023;


    /* MyArtifacts */
    ALTER TABLE "main"."FSMyArtifacts" RENAME TO "_FSMyArtifacts_old_20171023";

    CREATE TABLE "main"."FSMyArtifacts" (
      "localId" TEXT,
      "listType" INTEGER NOT NULL,
      "cacheHash" TEXT,
      "cisId" TEXT,
      "lastFetchDate" REAL NOT NULL,
      PRIMARY KEY("localId")
    );

    INSERT INTO "main"."FSMyArtifacts" ("localId", "listType", "cacheHash", "cisId", "lastFetchDate") SELECT "localId", "listType", "cacheHash", "cisId", "lastFetchDate" FROM "main"."_FSMyArtifacts_old_20171023";
    DROP TABLE _FSMyArtifacts_old_20171023;


    /* ParentChild */
    ALTER TABLE "main"."FSParentChild" RENAME TO "_FSParentChild_old_20171023";
    DROP INDEX "main"."INDEX_parentChild_server";

    CREATE TABLE "main"."FSParentChild" (
      "localId" TEXT,
      "relationshipId" TEXT,
      "childId" TEXT,
      "fatherId" TEXT,
      "motherId" TEXT,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "parentSortKey" INTEGER NOT NULL DEFAULT 0,
      "childSortKey" INTEGER NOT NULL DEFAULT 0,
      PRIMARY KEY("localId")
    );

    INSERT INTO "main"."FSParentChild" ("localId", "relationshipId", "childId", "fatherId", "motherId", "cacheHash", "lastFetchDate", "parentSortKey", "childSortKey") SELECT "localId", "relationshipId", "childId", "fatherId", "motherId", "cacheHash", "lastFetchDate", "parentSortKey", "childSortKey" FROM "main"."_FSParentChild_old_20171023";
    CREATE UNIQUE INDEX "main"."INDEX_parentChild_server" ON FSParentChild ("relationshipId" ASC);
    DROP TABLE _FSParentChild_old_20171023;


    /* Pedigree */
    ALTER TABLE "main"."FSPedigree" RENAME TO "_FSPedigree_old_20171023";
    DROP INDEX "main"."INDEX_pedigree_server";

    CREATE TABLE "main"."FSPedigree" (
      "localId" TEXT,
      "ancestorPids" TEXT,
      "pid" TEXT,
      "preferredSpousePid" TEXT,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      PRIMARY KEY("localId")
    );

    INSERT INTO "main"."FSPedigree" ("localId", "ancestorPids", "pid", "preferredSpousePid", "cacheHash", "lastFetchDate") SELECT "localId", "ancestorPids", "pid", "preferredSpousePid", "cacheHash", "lastFetchDate" FROM "main"."_FSPedigree_old_20171023";
    CREATE UNIQUE INDEX "main"."INDEX_pedigree_server" ON FSPedigree ("pid" ASC, "preferredSpousePid" ASC);
    DROP TABLE _FSPedigree_old_20171023;


    /* Person Artifacts */
    ALTER TABLE "main"."FSPersonArtifacts" RENAME TO "_FSPersonArtifacts_old_20171023";
    DROP INDEX "main"."INDEX_personArtifacts_server";

    CREATE TABLE "main"."FSPersonArtifacts" (
      "localId" TEXT,
      "pid" TEXT,
      "listType" INTEGER NOT NULL,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      PRIMARY KEY("localId")
    );

    INSERT INTO "main"."FSPersonArtifacts" ("localId", "pid", "listType", "cacheHash", "lastFetchDate") SELECT "localId", "pid", "listType", "cacheHash", "lastFetchDate" FROM "main"."_FSPersonArtifacts_old_20171023";
    CREATE UNIQUE INDEX "main"."INDEX_personArtifacts_server" ON FSPersonArtifacts ("pid" ASC);
    DROP TABLE _FSPersonArtifacts_old_20171023;


    /* PersonNote */
    ALTER TABLE "main"."FSPersonNote" RENAME TO "_FSPersonNote_old_20171023";
    DROP INDEX "main"."INDEX_note_server";

    CREATE TABLE "main"."FSPersonNote" (
      "localId" TEXT,
      "serverId" TEXT,
      "pid" TEXT,
      "subject" TEXT,
      "text" TEXT,
      "contributorId" text,
      "lastModified" INTEGER NOT NULL DEFAULT 0,
      "changeMessage" TEXT,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      PRIMARY KEY("localId")
    );

    INSERT INTO "main"."FSPersonNote" ("localId", "serverId", "pid", "subject", "text", "contributorId", "lastModified", "changeMessage", "cacheHash", "lastFetchDate") SELECT "localId", "serverId", "pid", "subject", "text", "contributorId", "lastModified", "changeMessage", "cacheHash", "lastFetchDate" FROM "main"."_FSPersonNote_old_20171023";
    CREATE UNIQUE INDEX "main"."INDEX_note_server" ON FSPersonNote ("serverId" ASC);
    DROP TABLE _FSPersonNote_old_20171023;


    /* PersonNoteList */
    ALTER TABLE "main"."FSPersonNoteList" RENAME TO "_FSPersonNoteList_old_20171023";
    DROP INDEX "main"."INDEX_noteList_server";

    CREATE TABLE "main"."FSPersonNoteList" (
      "localId" TEXT,
      "pid" TEXT,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      PRIMARY KEY("localId")
    );

    INSERT INTO "main"."FSPersonNoteList" ("localId", "pid", "cacheHash", "lastFetchDate") SELECT "localId", "pid", "cacheHash", "lastFetchDate" FROM "main"."_FSPersonNoteList_old_20171023";
    CREATE UNIQUE INDEX "main"."INDEX_noteList_server" ON FSPersonNoteList ("pid" ASC);
    DROP TABLE _FSPersonNoteList_old_20171023;


    /* RecordHint */
    ALTER TABLE "main"."FSRecordHint" RENAME TO "_FSRecordHint_old_20171023";
    DROP INDEX "main"."INDEX_recordHint_server";

    CREATE TABLE "main"."FSRecordHint" (
      "localId" TEXT,
      "serverId" TEXT,
      "matchedId" TEXT,
      "sourceLinkUrl" TEXT,
      "pid" TEXT,
      "title" TEXT,
      "collectionType" TEXT,
      "personName" TEXT,
      "score" REAL NOT NULL DEFAULT 0,
      "published" REAL NOT NULL DEFAULT 0,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      PRIMARY KEY("localId")
    );

    INSERT INTO "main"."FSRecordHint" ("localId", "serverId", "matchedId", "sourceLinkUrl", "pid", "title", "collectionType", "personName", "score", "published", "cacheHash", "lastFetchDate") SELECT "localId", "serverId", "matchedId", "sourceLinkUrl", "pid", "title", "collectionType", "personName", "score", "published", "cacheHash", "lastFetchDate" FROM "main"."_FSRecordHint_old_20171023";
    CREATE UNIQUE INDEX "main"."INDEX_recordHint_server" ON FSRecordHint ("serverId" ASC);
    DROP TABLE _FSRecordHint_old_20171023;


    /* Relationships */
    ALTER TABLE "main"."FSRelationships" RENAME TO "_FSRelationships_old_20171023";
    DROP INDEX "main"."INDEX_relationship_server";

    CREATE TABLE "main"."FSRelationships" (
      "localId" TEXT,
      "pid" TEXT,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      PRIMARY KEY("localId")
    );

    INSERT INTO "main"."FSRelationships" ("localId", "pid", "cacheHash", "lastFetchDate") SELECT "localId", "pid", "cacheHash", "lastFetchDate" FROM "main"."_FSRelationships_old_20171023";
    CREATE UNIQUE INDEX "main"."INDEX_relationship_server" ON FSRelationships ("pid" ASC);
    DROP TABLE _FSRelationships_old_20171023;


    /* Reservations */
    ALTER TABLE "main"."FSReservations" RENAME TO "_FSReservations_old_20171023";

    CREATE TABLE "main"."FSReservations" (
      "localId" TEXT,
      "personReservationIds" BLOB,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      PRIMARY KEY("localId")
    );

    INSERT INTO "main"."FSReservations" ("localId", "personReservationIds", "cacheHash", "lastFetchDate") SELECT "localId", "personReservationIds", "cacheHash", "lastFetchDate" FROM "main"."_FSReservations_old_20171023";
    DROP TABLE _FSReservations_old_20171023;


    /* MyAlbumList */
    ALTER TABLE "main"."MyAlbumsList" RENAME TO "_MyAlbumsList_old_20171023";

    CREATE TABLE "main"."MyAlbumsList" (
      "localId" TEXT,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      PRIMARY KEY("localId")
    );

    INSERT INTO "main"."MyAlbumsList" ("localId", "cacheHash", "lastFetchDate") SELECT "localId", "cacheHash", "lastFetchDate" FROM "main"."_MyAlbumsList_old_20171023";
    DROP TABLE _MyAlbumsList_old_20171023;


    /* Ordinance */
    ALTER TABLE "main"."Ordinance" RENAME TO "_Ordinance_old_20171023";
    DROP INDEX "main"."INDEX_ordinance_server";

    CREATE TABLE "main"."Ordinance" (
      "localId" TEXT,
      "assignedToTemple" INTEGER NOT NULL,
      "bornInCovenant" INTEGER NOT NULL,
      "canPrint" INTEGER NOT NULL,
      "completedDate" TEXT,
      "completedPlace" TEXT,
      "fatherId" TEXT,
      "fatherName" TEXT,
      "motherId" TEXT,
      "motherName" TEXT,
      "reserve" INTEGER NOT NULL,
      "spouseId" TEXT,
      "status" INTEGER NOT NULL,
      "type" INTEGER NOT NULL,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "personReservationPid" TEXT,
      "whyNotQualifying" TEXT DEFAULT NULL,
      "ownerName" TEXT DEFAULT '',
      "reservedDate" TEXT DEFAULT '',
      "comparableReservedDate" TEXT DEFAULT '',
      "requiresPermission" INTEGER NOT NULL,
      "canAssign" INTEGER NOT NULL DEFAULT 0,
      "canTransfer" INTEGER NOT NULL DEFAULT 0,
      "canUnreserve" INTEGER NOT NULL DEFAULT 0,
      "shareBatchId" STRING DEFAULT '',
      "shareComparableExpireDate" STRING DEFAULT '',
      "shareShareExpireDate" STRING DEFAULT '',
      "shareReceiveUrl" STRING DEFAULT '',
      PRIMARY KEY("localId")
    );

    INSERT INTO "main"."Ordinance" ("localId", "assignedToTemple", "bornInCovenant", "canPrint", "completedDate", "completedPlace", "fatherId", "fatherName", "motherId", "motherName", "reserve", "spouseId", "status", "type", "cacheHash", "lastFetchDate", "personReservationPid", "whyNotQualifying", "ownerName", "reservedDate", "comparableReservedDate", "requiresPermission", "canAssign", "canTransfer", "canUnreserve", "shareBatchId", "shareComparableExpireDate", "shareShareExpireDate", "shareReceiveUrl") SELECT "localId", "assignedToTemple", "bornInCovenant", "canPrint", "completedDate", "completedPlace", "fatherId", "fatherName", "motherId", "motherName", "reserve", "spouseId", "status", "type", "cacheHash", "lastFetchDate", "personReservationPid", "whyNotQualifying", "ownerName", "reservedDate", "comparableReservedDate", "requiresPermission", "canAssign", "canTransfer", "canUnreserve", "shareBatchId", "shareComparableExpireDate", "shareShareExpireDate", "shareReceiveUrl" FROM "main"."_Ordinance_old_20171023";
    CREATE UNIQUE INDEX "main"."INDEX_ordinance_server" ON Ordinance ("type" ASC, "personReservationPid" ASC, "fatherId" ASC, "motherId" ASC, "spouseId" ASC);
    DROP TABLE _Ordinance_old_20171023;


    /* PedigreePreferences */
    ALTER TABLE "main"."PedigreePreferences" RENAME TO "_PedigreePreferences_old_20171023";
    DROP INDEX "main"."INDEX_PedigreePreferences_pid";

    CREATE TABLE "main"."PedigreePreferences" (
      "localId" TEXT,
      "pid" TEXT NOT NULL,
      "preferredCoupleId" TEXT,
      "preferredParentChildId" TEXT,
      "preferredCoparentParentChildId" TEXT,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      PRIMARY KEY("localId")
    );

    INSERT INTO "main"."PedigreePreferences" ("localId", "pid", "preferredCoupleId", "preferredParentChildId", "preferredCoparentParentChildId", "cacheHash", "lastFetchDate") SELECT "localId", "pid", "preferredCoupleId", "preferredParentChildId", "preferredCoparentParentChildId", "cacheHash", "lastFetchDate" FROM "main"."_PedigreePreferences_old_20171023";
    CREATE UNIQUE INDEX "main"."INDEX_PedigreePreferences_pid" ON PedigreePreferences ("pid" ASC);
    DROP TABLE _PedigreePreferences_old_20171023;


    /* PersonReservation */
    ALTER TABLE "main"."PersonReservation" RENAME TO "_PersonReservation_old_20171023";
    DROP INDEX "main"."INDEX_personReservation_server";

    CREATE TABLE "main"."PersonReservation" (
      "localId" TEXT,
      "displayName" TEXT,
      "gender" TEXT,
      "givenName" TEXT,
      "lifespan" TEXT,
      "pid" TEXT,
      "surName" TEXT,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "hasDuplicate" INTEGER NOT NULL DEFAULT 0,
      PRIMARY KEY("localId")
    );

    INSERT INTO "main"."PersonReservation" ("localId", "displayName", "gender", "givenName", "lifespan", "pid", "surName", "cacheHash", "lastFetchDate", "hasDuplicate") SELECT "localId", "displayName", "gender", "givenName", "lifespan", "pid", "surName", "cacheHash", "lastFetchDate", "hasDuplicate" FROM "main"."_PersonReservation_old_20171023";
    CREATE UNIQUE INDEX "main"."INDEX_personReservation_server" ON PersonReservation ("pid" ASC);
    DROP TABLE _PersonReservation_old_20171023;


    /* PersonTasks */
    ALTER TABLE "main"."PersonTasks" RENAME TO "_PersonTasks_old_20171023";
    DROP INDEX "main"."INDEX_personTasks_listKey_pid";

    CREATE TABLE "main"."PersonTasks" (
      "localId" TEXT,
      "listKeyRaw" TEXT NOT NULL,
      "pid" TEXT NOT NULL,
      "sortKey" INTEGER NOT NULL,
      "hasHints" INTEGER NOT NULL,
      "templeStatus" INTEGER NOT NULL,
      "displayName" TEXT NOT NULL,
      "gender" INTEGER NOT NULL,
      "lifespan" TEXT,
      "living" INTEGER NOT NULL,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      PRIMARY KEY("localId")
    );

    INSERT INTO "main"."PersonTasks" ("localId", "listKeyRaw", "pid", "sortKey", "hasHints", "templeStatus", "displayName", "gender", "lifespan", "living", "cacheHash", "lastFetchDate") SELECT "localId", "listKeyRaw", "pid", "sortKey", "hasHints", "templeStatusRaw", "displayName", "genderRaw", "lifespan", "living", "cacheHash", "lastFetchDate" FROM "main"."_PersonTasks_old_20171023";
    CREATE UNIQUE INDEX "main"."INDEX_personTasks_listKey_pid" ON PersonTasks ("listKeyRaw" ASC, "pid" ASC);
    DROP TABLE _PersonTasks_old_20171023;


    /* PersonTasksLists */
    ALTER TABLE "main"."PersonTasksList" RENAME TO "_PersonTasksList_old_20171023";
    DROP INDEX "main"."INDEX_personTasksList_listKey";

    CREATE TABLE "main"."PersonTasksList" (
      "localId" TEXT,
      "listKeyRaw" TEXT NOT NULL,
      "numGens" INTEGER,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      PRIMARY KEY("localId")
    );

    INSERT INTO "main"."PersonTasksList" ("localId", "listKeyRaw", "numGens", "cacheHash", "lastFetchDate") SELECT "localId", "listKeyRaw", "numGens", "cacheHash", "lastFetchDate" FROM "main"."_PersonTasksList_old_20171023";
    CREATE UNIQUE INDEX "main"."INDEX_personTasksList_listKey" ON PersonTasksList ("listKeyRaw" ASC);
    DROP TABLE _PersonTasksList_old_20171023;
    """,

    """
    CREATE TABLE "main"."GeoEvent" (
      "localId" TEXT,
      "eventId" TEXT NOT NULL,
      "name" TEXT NOT NULL,
      "startTimestamp" REAL NOT NULL,
      "endTimestamp" REAL NOT NULL,
      "geofenceCenterLatitude" REAL NOT NULL,
      "geofenceCenterLongitude" REAL NOT NULL,
      "geofenceRadius" REAL NOT NULL,
      "optedIn" INTEGER NOT NULL,
      "colorHex" TEXT NOT NULL,
      "imageUrl" TEXT NOT NULL,
      "introText" TEXT NOT NULL,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      PRIMARY KEY("localId")
    );

    CREATE UNIQUE INDEX "main"."INDEX_geoEvent_eventId" ON GeoEvent ("eventId");

    CREATE TABLE "main"."GeoEventList" (
      "localId" TEXT,
      "listId" TEXT,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      PRIMARY KEY("localId")
    );

    CREATE UNIQUE INDEX "main"."INDEX_geoEventList_listId" ON GeoEventList ("listId");
    """,

    """
    CREATE TABLE "main"."SyncTask" (
      "localId" TEXT NOT NULL,
      "type" TEXT NOT NULL,
      "primaryLocalId" TEXT NOT NULL,
      "createdOn" INTEGER NOT NULL,
      "state" TEXT NOT NULL,
      "attemptCount" INTEGER NOT NULL,
      "lastAttemptDate" INTEGER NOT NULL,
      "message" TEXT,
      PRIMARY KEY("localId")
    );

    CREATE TABLE "main"."CacheTracker" (
      "localId" TEXT PRIMARY KEY,
      "typeRaw" TEXT,
      "entityId" TEXT,

      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL
    );
    CREATE UNIQUE INDEX "main"."INDEX_CacheTracker_typeRaw_entityId" ON CacheTracker ("typeRaw" ASC, "entityId" ASC);


    /* Drop artifactServerId column from the FSSource table */
    ALTER TABLE "main"."FSSource" RENAME TO "_FSSource_old_20171222";
    DROP INDEX "main"."INDEX_source_server";

    CREATE TABLE "main"."Source" (
      "localId" TEXT,
      "artifactLocalId" TEXT,
      "serverId" TEXT,
      "title" TEXT,
      "url" TEXT,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "syncInFlightStatus" INTEGER NOT NULL,
      "syncStatus" INTEGER NOT NULL,
      "notes" TEXT DEFAULT '',
      "citation" TEXT DEFAULT '',
      "contributorCisId" TEXT DEFAULT '',
      "modifiedTimestamp" INTEGER NOT NULL DEFAULT 0,
      "resourceType" TEXT '',
      "changeMessage" TEXT '',
      PRIMARY KEY("localId")
    );

    INSERT INTO "main"."Source" ("localId", "artifactLocalId", "serverId", "title", "url", "cacheHash", "lastFetchDate", "syncInFlightStatus", "syncStatus", "notes", "citation", "contributorCisId", "modifiedTimestamp", "resourceType", "changeMessage") SELECT "localId", "artifactLocalId", "serverId", "title", "url", "cacheHash", "lastFetchDate", "syncInFlightStatus", "syncStatus", "notes", "citation", "contributorCisId", "modifiedTimestamp", "resourceType", "changeMessage" FROM "main"."_FSSource_old_20171222";
    CREATE UNIQUE INDEX "main"."INDEX_source_server" ON Source ("serverId" ASC);
    DROP TABLE _FSSource_old_20171222;


    /* Drop artifactServerId, taggedPersonServerId, personaServerId and rename table */
    DROP INDEX "main"."INDEX_photoTag_server";
    DROP TABLE FSPhotoTag;

    CREATE TABLE "main"."Tag" (
      "localId" TEXT,
      "serverId" TEXT,
      "deletable" INTEGER NOT NULL DEFAULT 0,
      "editable" INTEGER NOT NULL DEFAULT 0,
      "height" REAL NOT NULL DEFAULT 0,
      "softTag" INTEGER NOT NULL DEFAULT 0,
      "artifactLocalId" TEXT,
      "taggedPersonLocalId" TEXT,
      "personaLocalId" STRING DEFAULT NULL,
      "taggedPersonPid" STRING DEFAULT '',
      "title" TEXT,
      "width" REAL NOT NULL DEFAULT 0,
      "x" REAL NOT NULL DEFAULT 0,
      "y" REAL NOT NULL DEFAULT 0,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "syncInFlightStatus" INTEGER NOT NULL,
      "syncStatus" INTEGER NOT NULL,
      PRIMARY KEY("localId")
    );

    CREATE UNIQUE INDEX "main"."INDEX_Tag_server" ON Tag ("serverId" ASC);


    /* Drop tables used to track things that CacheTracker can now be used for */
    DROP TABLE FSSourceReferenceList;
    DROP TABLE FSRelationships;
    DROP TABLE FSPersonNoteList;
    DROP TABLE FSHistoryList;
    DROP TABLE FSHintList;
    DROP TABLE GeoEventList;
    """,

    """
    ALTER TABLE FSPersonVitals ADD readOnly INTEGER NOT NULL DEFAULT 0;

    ALTER TABLE FSRecordHint ADD primaryEventType TEXT;

    ALTER TABLE Ordinance ADD owner STRING DEFAULT '';

    /* Album */
    ALTER TABLE "main"."Album" RENAME TO "_Album_old_20181023";
    DROP INDEX "main"."INDEX_album_server";

    CREATE TABLE "main"."Album" (
    "localId" TEXT,
    "serverId" TEXT,
    "listType" INTEGER NOT NULL,
    "albumName" TEXT,
    "albumDescription" TEXT,
    "contributorPatronId" INTEGER NOT NULL,
    "uploaderId" INTEGER NOT NULL,
    "restrictionState" TEXT NOT NULL,
    "artifactCount" INTEGER NOT NULL,
    "thumbUrl" TEXT,
    "thumbSquareUrl" TEXT,
    "thumbIconUrl" TEXT,
    "seoIndexable" INTEGER NOT NULL,
    "favorite" INTEGER NOT NULL,
    "editableByCaller" INTEGER NOT NULL,
    "cacheHash" TEXT,
    "lastFetchDate" REAL NOT NULL,
    PRIMARY KEY("localId")
    );

    INSERT INTO "main"."Album" ("localId", "serverId", "listType", "albumName", "albumDescription", "contributorPatronId", "uploaderId", "restrictionState", "artifactCount", "thumbUrl", "thumbSquareUrl", "thumbIconUrl", "seoIndexable", "favorite", "editableByCaller", "cacheHash", "lastFetchDate") SELECT "localId", "serverId", "listType", "albumName", "albumDescription", "contributorPatronId", "uploaderId", "restrictionState", "artifactCount", "thumbUrl", "thumbSquareUrl", "thumbIconUrl", "seoIndexable", "favorite", "editableByCaller", "cacheHash", "lastFetchDate" FROM "main"."_Album_old_20181023";
    CREATE UNIQUE INDEX "main"."INDEX_album_server" ON Album ("serverId" ASC);
    DROP TABLE _Album_old_20181023;
    """,

    """
    ALTER TABLE FSArtifact ADD iconLocalId TEXT;

    """,

    """
    ALTER TABLE FSSourceReference ADD nameTagged INTEGER NOT NULL DEFAULT 0;
    ALTER TABLE FSSourceReference ADD genderTagged INTEGER NOT NULL DEFAULT 0;
    ALTER TABLE FSSourceReference ADD birthTagged INTEGER NOT NULL DEFAULT 0;
    ALTER TABLE FSSourceReference ADD christeningTagged INTEGER NOT NULL DEFAULT 0;
    ALTER TABLE FSSourceReference ADD deathTagged INTEGER NOT NULL DEFAULT 0;
    ALTER TABLE FSSourceReference ADD burialTagged INTEGER NOT NULL DEFAULT 0;

    ALTER TABLE FSPersonVitals ADD confidential INTEGER NOT NULL DEFAULT 0;
    """,

    """
    CREATE TABLE "main"."XTGroup" (
      "localId" TEXT,
      "groupId" TEXT,
      "title" TEXT,
      "description" TEXT,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      PRIMARY KEY("localId")
    );
    CREATE UNIQUE INDEX "main"."INDEX_xtgroup_groupId" ON XTGroup ("groupId" ASC);

    CREATE TABLE "main"."XTGroupMember" (
      "localId" TEXT,
      "id" TEXT,
      "groupId" TEXT,
      "displayName" TEXT,
      "cisId" TEXT,
      "thumbUrl" TEXT,
      "gender" TEXT,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      PRIMARY KEY("localId")
    );
    CREATE UNIQUE INDEX "main"."INDEX_xtgroupmember_groupId_cisid" ON XTGroupMember ("cisId", "groupId" ASC);

    ALTER TABLE Ordinance ADD xtSharedWithGroupId TEXT DEFAULT NULL;
    ALTER TABLE Ordinance ADD xtReservationId INTEGER DEFAULT -1;
    ALTER TABLE Ordinance ADD xtSharedByMe INTEGER DEFAULT 0;
    ALTER TABLE Ordinance ADD xtOriginalOwnerId TEXT DEFAULT NULL;

    CREATE TABLE "main"."XTMessage" (
      "localId" TEXT,
      "groupId" TEXT,
      "messageId" INTEGER NOT NULL DEFAULT 0,
      "parentMessageId" INTEGER DEFAULT 0,
      "cisId" TEXT,
      "dataString" TEXT,
      "type" TEXT,
      "createDate" INTEGER NOT NULL DEFAULT 0,
      "updateDate" INTEGER NOT NULL DEFAULT 0,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      PRIMARY KEY("localId")
    );
    CREATE UNIQUE INDEX "main"."INDEX_xtmessage_messageId" ON XTMessage ("messageId" ASC);
    """,

    """
    ALTER TABLE Ordinance ADD expiryDate TEXT DEFAULT '';
    ALTER TABLE Ordinance ADD comparableExpiryDate TEXT DEFAULT '';
    """,

    """
    ALTER TABLE FSFact ADD dateMonth INTEGER NOT NULL DEFAULT 0;
    ALTER TABLE FSFact ADD dateDay INTEGER NOT NULL DEFAULT 0;

    CREATE TABLE "Portrait" (
      "localId" TEXT,
      "serverId" TEXT,
      "pid" TEXT,
      "x" REAL,
      "y" REAL,
      "width" REAL,
      "height" REAL,
      "rotation" REAL,
      "processingState" TEXT,
      "screeningState" TEXT,
      "artifactLocalId" TEXT,
      "artifactServerId" TEXT,
      "reason" TEXT,
      "originalUrl" TEXT,
      "thumbIconUrl" TEXT,
      "thumbSquareUrl" TEXT,
      "mediaType" TEXT,
      "cacheHash" TEXT,
      "syncInFlightStatus" INTEGER NOT NULL,
      "syncStatus" INTEGER NOT NULL,
      PRIMARY KEY("localId")
    );

    CREATE UNIQUE INDEX "main"."INDEX_portrait_pid" ON Portrait ("pid");

    DROP TABLE FSPersonPotentialPortrait;
    """,

    """
    ALTER TABLE XTGroupMember ADD role TEXT NOT NULL DEFAULT "MEMBER";
    ALTER TABLE XTGroupMember ADD statsString TEXT;
    ALTER TABLE XTGroup ADD statsString TEXT;

    CREATE TABLE "main"."XTMessageActivity" (
      "localId" TEXT,
      "activityId" INTEGER,
      "cisId" TEXT,
      "action" TEXT,
      "entityType" TEXT,
      "entityId" TEXT,
      "quantity" INTEGER,
      "activityTimestamp" REAL,
      PRIMARY KEY("localId")
    );
    CREATE UNIQUE INDEX "main"."INDEX_xtmessageactivity_activityId" ON XTMessageActivity ("activityId" ASC);
    """,

    """
    ALTER TABLE XTGroup ADD experimentEnd REAL;
    """,

    """
    ALTER TABLE FSArtifact ADD parentArtifactLocalId TEXT DEFAULT NULL;
    """,

    """
    ALTER TABLE FSFOR ADD forNumber TEXT DEFAULT NULL;
    """,

    """
    ALTER TABLE Artifact_Associations ADD sortOrder INTEGER NOT NULL DEFAULT 0;
    """,

    """
    ALTER TABLE FSUser ADD cardsNotReturned INTEGER NOT NULL DEFAULT 0;
    """,

    """
    UPDATE FSFact SET ownerEntityId = REPLACE(ownerEntityId, 'mother', 'parent2');
    UPDATE FSFact SET ownerEntityId = REPLACE(ownerEntityId, 'father', 'parent1');

    ALTER TABLE "main"."FSParentChild" RENAME TO "_FSParentChild_old_20190402";
    DROP INDEX "main"."INDEX_parentChild_server";

    CREATE TABLE "main"."ParentChild" (
      "localId" TEXT,
      "relationshipId" TEXT,
      "childId" TEXT,
      "parent1Id" TEXT,
      "parent2Id" TEXT,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "parentSortKey" INTEGER NOT NULL DEFAULT 0,
      "childSortKey" INTEGER NOT NULL DEFAULT 0,
      PRIMARY KEY("localId")
    );

    INSERT INTO "main"."ParentChild" ("localId", "relationshipId", "childId", "parent1Id", "parent2Id", "cacheHash", "lastFetchDate", "parentSortKey", "childSortKey") SELECT "localId", "relationshipId", "childId", "fatherId", "motherId", "cacheHash", "lastFetchDate", "parentSortKey", "childSortKey" FROM "main"."_FSParentChild_old_20190402";
    CREATE UNIQUE INDEX "main"."INDEX_parentChild_server" ON ParentChild ("relationshipId" ASC);
    DROP TABLE _FSParentChild_old_20190402;



    ALTER TABLE "main"."Ordinance" RENAME TO "_Ordinance_old_20190402";
    DROP INDEX "main"."INDEX_ordinance_server";

    CREATE TABLE "main"."Ordinance" (
      "localId" TEXT,
      "assignedToTemple" INTEGER NOT NULL,
      "bornInCovenant" INTEGER NOT NULL,
      "canPrint" INTEGER NOT NULL,
      "completedDate" TEXT,
      "completedPlace" TEXT,
      "parent1Id" TEXT,
      "parent1Name" TEXT,
      "parent1Gender" INTEGER,
      "parent2Id" TEXT,
      "parent2Name" TEXT,
      "parent2Gender" INTEGER,
      "reserve" INTEGER NOT NULL,
      "spouseId" TEXT,
      "status" INTEGER NOT NULL,
      "type" INTEGER NOT NULL,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "personReservationPid" TEXT,
      "whyNotQualifying" TEXT DEFAULT NULL,
      "ownerName" TEXT DEFAULT '',
      "reservedDate" TEXT DEFAULT '',
      "comparableReservedDate" TEXT DEFAULT '',
      "requiresPermission" INTEGER NOT NULL,
      "canAssign" INTEGER NOT NULL DEFAULT 0,
      "canTransfer" INTEGER NOT NULL DEFAULT 0,
      "canUnreserve" INTEGER NOT NULL DEFAULT 0,
      "shareBatchId" STRING DEFAULT '',
      "shareComparableExpireDate" STRING DEFAULT '',
      "shareShareExpireDate" STRING DEFAULT '',
      "shareReceiveUrl" STRING DEFAULT '',
      "owner" STRING DEFAULT '',
      "xtSharedWithGroupId" TEXT DEFAULT NULL,
      "xtReservationId" INTEGER DEFAULT -1,
      "xtSharedByMe" INTEGER DEFAULT 0,
      "xtOriginalOwnerId" TEXT DEFAULT NULL,
      "expiryDate" TEXT DEFAULT '',
      "comparableExpiryDate" TEXT DEFAULT '',
      PRIMARY KEY("localId")
    );

    INSERT INTO "main"."Ordinance" ("localId", "assignedToTemple", "bornInCovenant", "canPrint", "completedDate", "completedPlace", "parent1Id", "parent1Name", "parent1Gender", "parent2Id", "parent2Name", "parent2Gender", "reserve", "spouseId", "status", "type", "cacheHash", "lastFetchDate", "personReservationPid", "whyNotQualifying", "ownerName", "reservedDate", "comparableReservedDate", "requiresPermission", "canAssign", "canTransfer", "canUnreserve", "shareBatchId", "shareComparableExpireDate", "shareShareExpireDate", "shareReceiveUrl", "owner", "xtSharedWithGroupId", "xtReservationId", "xtSharedByMe", "xtOriginalOwnerId", "expiryDate", "comparableExpiryDate") SELECT "localId", "assignedToTemple", "bornInCovenant", "canPrint", "completedDate", "completedPlace", "fatherId", "fatherName", 1, "motherId", "motherName", 2, "reserve", "spouseId", "status", "type", "cacheHash", "lastFetchDate", "personReservationPid", "whyNotQualifying", "ownerName", "reservedDate", "comparableReservedDate", "requiresPermission", "canAssign", "canTransfer", "canUnreserve", "shareBatchId", "shareComparableExpireDate", "shareShareExpireDate", "shareReceiveUrl", "owner", "xtSharedWithGroupId", "xtReservationId", "xtSharedByMe", "xtOriginalOwnerId", "expiryDate", "comparableExpiryDate" FROM "main"."_Ordinance_old_20190402";
    CREATE UNIQUE INDEX "main"."INDEX_ordinance_server" ON Ordinance ("type" ASC, "personReservationPid" ASC, "parent1Id" ASC, "parent2Id" ASC, "spouseId" ASC);
    DROP TABLE _Ordinance_old_20190402;

    CREATE TABLE "main"."OtherApp" (
      "name" TEXT NOT NULL,
      "appStoreUrl" TEXT NOT NULL,
      "imageUrl" TEXT NOT NULL,
      "urlScheme" TEXT
    );
    CREATE UNIQUE INDEX "main"."INDEX_OtherApp_appStoreUrl" ON OtherApp ("appStoreUrl" ASC);


    /* Contributor Table Updates */
    DROP INDEX "main"."INDEX_contributor_server";
    DROP TABLE FSContributor;

    CREATE TABLE "main"."FSContributor" (
      "localId" TEXT NOT NULL,
      "key" TEXT,
      "contributorId" TEXT,
      "artifactPatronId" TEXT,
      "contactName" TEXT,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "email" STRING DEFAULT '',
      "phoneNumber" STRING DEFAULT '',
      "cisUserId" STRING DEFAULT '',
      "relationshipPathData" blob,
      "relationshipDescription" TEXT,
      "optedInToUserRelationship" integer NOT NULL DEFAULT 0,
      "surname" TEXT DEFAULT NULL,
      "givenName" TEXT DEFAULT NULL,
      PRIMARY KEY("localId")
    );

    CREATE UNIQUE INDEX "main"."INDEX_contributor_server" ON FSContributor ("contributorId" ASC);
    """,

    """
    CREATE TABLE "DCamItem" (
      "localId" TEXT,
      "workstationId" TEXT,
      "direction" TEXT,
      "fileName" TEXT,
      "uploadUrl" TEXT,
      "capturedOn" REAL,
      "transferedOn" REAL,
      "cacheHash" TEXT,
      "syncInFlightStatus" INTEGER NOT NULL,
      "syncStatus" INTEGER NOT NULL,
      PRIMARY KEY("localId")
    );

    CREATE TABLE "DCamWorkstation" (
      "localId" TEXT,
      "workstationId" TEXT,
      "projectIds" BLOB,
      "nickName" TEXT,
      "ipAddress" TEXT,
      PRIMARY KEY("localId")
    );

    CREATE UNIQUE INDEX "main"."INDEX_dcamworkstation_workstationId" ON DCamWorkstation ("workstationId");
    """,

    """
    ALTER TABLE FSUser ADD gender INTEGER;
    """,

    """
    CREATE TABLE "ArtifactDatePlace" (
      "localId" TEXT,
      "serverId" TEXT DEFAULT NULL,
      "artifactLocalId" TEXT,
      "dateNonStandardizedText" TEXT DEFAULT NULL,
      "dateNormalizedText" TEXT DEFAULT NULL,
      "placeRepId" TEXT DEFAULT NULL,
      "placeNormalizedText" TEXT DEFAULT NULL,
      "placeNonStandardizedText" TEXT DEFAULT NULL,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "syncInFlightStatus" INTEGER NOT NULL,
      "syncStatus" INTEGER NOT NULL,
      PRIMARY KEY("localId")
    );
    CREATE UNIQUE INDEX "main"."INDEX_artifactDatePlace_server" ON ArtifactDatePlace ("serverId");
    """,

    """
    ALTER TABLE FSContributor ADD invitePending INTEGER NOT NULL DEFAULT 0;

    ALTER TABLE Source ADD displayDate TEXT;
    ALTER TABLE Source ADD sortYear TEXT;
    ALTER TABLE Source ADD sortKey TEXT;
    """,

    """
    CREATE TABLE "ArtifactComment" (
      "localId" TEXT,
      "commentId" TEXT,
      "artifactLocalId" TEXT,
      "text" TEXT,
      "cisId" TEXT,
      "createdDate" REAL,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "syncInFlightStatus" INTEGER NOT NULL,
      "syncStatus" INTEGER NOT NULL,
      PRIMARY KEY("localId")
    );
    CREATE UNIQUE INDEX "main"."INDEX_artifactComment_commentId" ON ArtifactComment ("commentId");
    """,

    """
    ALTER TABLE FSConversation ADD folderFilter TEXT;

    CREATE TABLE "ConversationFolder" (
      "localId" TEXT,
      "folderFilter" TEXT,
      "displayName" TEXT,
      "newMessageCount" INTEGER,
      "sortOrder" INTEGER,
      PRIMARY KEY("localId")
    );
    """,

    """
    ALTER TABLE "main"."FSPersonVitals" RENAME TO "_FSPersonVitals_old_20191218";

    DROP INDEX "main"."INDEX_person_server";

    CREATE TABLE "main"."Person" (
       "localId" TEXT,
       "pid" TEXT NOT NULL,
       "displayName" TEXT,
       "givenName" TEXT,
       "surName" TEXT,
       "suffix" TEXT,
       "nameOrder" TEXT DEFAULT "eurotypic",
       "nameSeparator" TEXT DEFAULT " ",
       "gender" INTEGER,
       "lifespan" TEXT,
       "living" INTEGER NOT NULL DEFAULT 0,
       "readOnly" INTEGER NOT NULL DEFAULT 0,
       "confidential" INTEGER NOT NULL DEFAULT 0,
       "photoCount" INTEGER,
       "sourceCount" INTEGER,
       "storyCount" INTEGER,
       "researchSuggestionCount" INTEGER,
       "dataProblemCount" INTEGER,
       "birthCountry" TEXT,
       "hasRecordHints" INTEGER,
       "hasPossibleDuplicates" INTEGER,
       "templeStatus" TEXT,
       "cacheHash" TEXT,
       "lastFetchDate" REAL NOT NULL,
      PRIMARY KEY("localId")
    );

    INSERT INTO "main"."Person" ("localId", "pid", "displayName", "givenName", "surName", "suffix", "gender", "lifespan", "living", "readOnly", "confidential", "cacheHash", "lastFetchDate") SELECT "localId", "pid", "displayName", "givenName", "surName", "suffix", "gender", "lifespan", "living", "readOnly", "confidential", "cacheHash", "lastFetchDate" FROM "main"."_FSPersonVitals_old_20191218";
    CREATE UNIQUE INDEX "main"."INDEX_person_server" ON Person ("pid" ASC);
    DROP TABLE _FSPersonVitals_old_20191218;


    CREATE TABLE "main"."FanChart" (
       "localId" TEXT,
       "pid" TEXT NOT NULL,
       "generations" INTEGER,
       "dataOptions" INTEGER,
       "cacheHash" TEXT,
       "lastFetchDate" REAL NOT NULL,
      PRIMARY KEY("localId")
    );
    CREATE UNIQUE INDEX "main"."INDEX_FanChart_server" ON FanChart ("pid", "generations", "dataOptions");

    CREATE TABLE "main"."FanChartPosition" (
       "rootPid" TEXT NOT NULL,
       "position" TEXT NOT NULL,
       "generations" INTEGER NOT NULL,
       "pid" TEXT
    );

    ALTER TABLE FSContributor ADD hasContacted INTEGER;
    ALTER TABLE FSContributor ADD isConsultant INTEGER;
    ALTER TABLE FSContributor ADD displayName TEXT;
    """,

    """
    CREATE TABLE "ArtifactTopicTag" (
      "localId" TEXT,
      "topicId" TEXT,
      "artifactLocalId" TEXT,
      "text" TEXT,
      "useCount" INTEGER,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "syncInFlightStatus" INTEGER NOT NULL,
      "syncStatus" INTEGER NOT NULL,
      PRIMARY KEY("localId")
    );
    CREATE UNIQUE INDEX "main"."INDEX_artifactTopicTag_topicId" ON ArtifactTopicTag ("topicId", "artifactLocalId");
    """,

    """
    ALTER TABLE Source ADD unfinishedAttachments INTEGER NOT NULL DEFAULT 0;
    ALTER TABLE List_Artifact ADD sortKey INTEGER NOT NULL DEFAULT 0;

    /* Data Fixup to retry tags that failed because of a 409 error */
    UPDATE Tag
    SET syncStatus = 1,
        syncInFlightStatus = 3
    WHERE localId IN (
      SELECT primaryLocalId FROM SyncTask
      WHERE type = 'tagAdd' AND
            state = 'failed' AND
            message LIKE '%org.familysearch.tag.create.failed Code=409%'
    );

    UPDATE SyncTask
    SET state = 'ready', message = NULL
    WHERE type = 'tagAdd' AND
          state = 'failed' AND
          message LIKE '%org.familysearch.tag.create.failed Code=409%';
    """,

    """
    DROP TABLE Ordinance;
    DROP TABLE FSReservations;
    DROP TABLE PersonReservation;
    DROP TABLE XTGroup;
    DROP TABLE XTGroupMember;
    DROP TABLE XTMessage;
    DROP TABLE XTMessageActivity;

    UPDATE Person SET templeStatus = REPLACE(templeStatus, 'unknown', 'COMPLETED');
    UPDATE Person SET templeStatus = REPLACE(templeStatus, 'completed', 'COMPLETED');
    UPDATE Person SET templeStatus = REPLACE(templeStatus, 'reserved', 'RESERVED');
    UPDATE Person SET templeStatus = REPLACE(templeStatus, 'ready', 'READY');
    UPDATE Person SET templeStatus = REPLACE(templeStatus, 'needsMoreInformation', 'NEED_MORE_INFORMATION');
    UPDATE Person SET templeStatus = REPLACE(templeStatus, 'needsPermission', 'NEED_PERMISSION');
    UPDATE Person SET templeStatus = REPLACE(templeStatus, 'notReady', 'NOT_READY');

    CREATE TABLE "main"."Ordinance" (
       "localId" text NOT NULL,
       "ownerEntityId" text NOT NULL,
       "personId" text,
       "spouseId" text,
       "parent1Id" text,
       "parent2Id" text,
       "type" text,
       "status" text,
       "printable" integer,
       "reservable" integer,
       "unReservable" integer,
       "shareable" integer,
       "unShareable" integer,
       "transferable" integer,
       "ownerId" text,
       "ownerContactName" text,
       "reserveTime" real,
       "expireTime" real,
       "sharedWithTempleTime" real,
       "templeDisplayDate" text,
       "templeDisplayPlace" text,
       "uniqueIdentifier" text NOT NULL,
       "displayStatusData" blob,
      PRIMARY KEY("localId")
    );
    CREATE UNIQUE INDEX "main"."INDEX_ordinance_unique" ON Ordinance ("uniqueIdentifier");

    CREATE TABLE "main"."Card" (
       "localId" text NOT NULL,
       "type" text,
       "status" text,
       "assignmentType" text,
       "sortOrder" text,
       "personId" text,
       "spouseId" text,
       "parent1Id" text,
       "parent2Id" text,
       "sortKey" real,
       "reservable" integer,
       "printable" integer,
       "unReservable" integer,
       "shareable" integer,
       "unShareable" integer,
       "transferable" integer,
       "reserveTime" real,
       "expireTime" real,
       "visibleContentHash" text,
       "transferUrl" text,
       "transferExpireTime" real,
       "sharedWithTempleTime" real,
       "messagesData" blob,
      PRIMARY KEY("localId")
    );
    CREATE UNIQUE INDEX "main"."INDEX_cards_ids" ON "Card" ("type", "assignmentType", "sortOrder", "personId", "spouseId");

    CREATE TABLE "ReservationList" (
      "localId" TEXT PRIMARY KEY,
      "contributorId" TEXT NOT NULL,
      "assignmentType" TEXT NOT NULL,
      "sortOrder" TEXT NOT NULL,
      "personalCardCount" INTEGER,
      "templeSharedCardCount" INTEGER,
      "completedCount" INTEGER,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL
    );
    CREATE UNIQUE INDEX "main"."INDEX_reservationList" ON "ReservationList" ("contributorId", "assignmentType", "sortOrder");

    DROP TABLE FSPedigree;

    CREATE TABLE "main"."Tree" (
      "localId" TEXT,
      "_root1Pid" TEXT NOT NULL,
      "_root2Pid" TEXT NOT NULL,
      "ownerEntityId" TEXT NOT NULL,
      "dataOptions" INTEGER,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      PRIMARY KEY("localId")
    );
    CREATE UNIQUE INDEX "main"."INDEX_Tree_server" ON Tree ("_root1Pid", "_root2Pid", "dataOptions");

    CREATE TABLE "main"."TreePosition" (
      "ownerEntityId" TEXT NOT NULL,
      "rootPid" TEXT NOT NULL,
      "position" TEXT NOT NULL,
      "pid" TEXT
    );

    ALTER TABLE Place ADD localizedType TEXT;
    """,

    """
    ALTER TABLE Ordinance ADD secondaryOwnerId TEXT;
    ALTER TABLE Ordinance ADD secondaryOwnerContactName TEXT;
    ALTER TABLE Ordinance ADD secondaryReserveTime REAL;
    ALTER TABLE Ordinance ADD secondaryExpireTime REAL;

    ALTER TABLE Card ADD ownerId TEXT;
    ALTER TABLE Card ADD ownerContactName TEXT;
    ALTER TABLE Card ADD secondaryOwnerId TEXT;
    ALTER TABLE Card ADD secondaryOwnerContactName TEXT;
    ALTER TABLE Card ADD secondaryReserveTime REAL;
    ALTER TABLE Card ADD secondaryExpireTime REAL;

    ALTER TABLE FSMyArtifacts ADD archiveState TEXT NOT NULL DEFAULT notArchived;
    """,
    
    """
    DROP TABLE Artifact_Associations;
    DROP TABLE FSConversation;
    DROP TABLE FSFOR;
    DROP TABLE FSMessage;
    DROP TABLE FSMyTaggedPersons;
    DROP TABLE FSPersona;
    DROP TABLE FSSourceReference;
    DROP TABLE FSTaggedPerson;
    DROP TABLE FSWatch;
    DROP TABLE List_Artifact;
    DROP TABLE Place;
    DROP TABLE FSCouple;
    DROP TABLE FSDescendants;
    DROP TABLE DataHint;
    DROP TABLE FSArtifact;
    DROP TABLE ScopeAncestor;
    DROP TABLE FSFact;
    DROP TABLE FSHistoryItem;
    DROP TABLE FSUser;
    DROP TABLE FSMyArtifacts;
    DROP TABLE FSPersonArtifacts;
    DROP TABLE FSPersonNote;
    DROP TABLE FSRecordHint;
    DROP TABLE MyAlbumsList;
    DROP TABLE PedigreePreferences;
    DROP TABLE PersonTasks;
    DROP TABLE PersonTasksList;
    DROP TABLE GeoEvent;
    DROP TABLE SyncTask;
    DROP TABLE CacheTracker;
    DROP TABLE Source;
    DROP TABLE Tag;
    DROP TABLE Album;
    DROP TABLE Portrait;
    DROP TABLE ParentChild;
    DROP TABLE OtherApp;
    DROP TABLE FSContributor;
    DROP TABLE DCamItem;
    DROP TABLE DCamWorkstation;
    DROP TABLE ArtifactDatePlace;
    DROP TABLE ArtifactComment;
    DROP TABLE ConversationFolder;
    DROP TABLE Person;
    DROP TABLE FanChart;
    DROP TABLE FanChartPosition;
    DROP TABLE ArtifactTopicTag;
    DROP TABLE Ordinance;
    DROP TABLE Card;
    DROP TABLE ReservationList;
    DROP TABLE Tree;
    DROP TABLE TreePosition;
    """,
    
    //HERE IS A COPY OF ALL OF THE PREVIOUS COMMANDS WITH SLIGHTLY MODIFIED NAMES
    
    """
    CREATE TABLE "Artifact_Associations" (
      "artifact1LocalId" TEXT,
      "artifact2LocalId" TEXT,
      "deleted" INTEGER DEFAULT 0
    );

    CREATE TABLE "DataHint" (
      "localId" TEXT PRIMARY KEY,
      "pid" TEXT,
      "categoryRaw" TEXT,
      "typeRaw" TEXT,
      "contextRaw" TEXT,
      "canBeDismissed" INTEGER NOT NULL DEFAULT 0,
      "entityId" TEXT,
      "contextId" TEXT,
      "sortKey" INTEGER
    );

    CREATE TABLE "FSArtifact" (
      "localId" TEXT,
      "serverId" TEXT,
      "typeRaw" INTEGER NOT NULL,
      "url" TEXT,
      "thumbUrl" TEXT,
      "desc" TEXT,
      "title" TEXT,
      "mimeType" TEXT,
      "restricted" INTEGER NOT NULL,
      "editableByCaller" INTEGER NOT NULL,
      "category" TEXT,
      "contentCategory" TEXT,
      "uploadedOn" REAL NOT NULL,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "syncInFlightStatus" INTEGER NOT NULL,
      "syncStatus" INTEGER NOT NULL,
      "duration" INTEGER NOT NULL DEFAULT 0,
      "height" INTEGER NOT NULL DEFAULT 0,
      "width" INTEGER NOT NULL DEFAULT 0,
      "size" INTEGER NOT NULL DEFAULT 0,
      "fullText" TEXT,
      "artifactPatronId" TEXT DEFAULT NULL,
      "deepZoomLiteUrl" TEXT DEFAULT NULL,
      "portraitPhotoTagLocalId" TEXT,
      PRIMARY KEY("localId")
    );

    CREATE TABLE "FSContributor" (
      "localId" TEXT NOT NULL,
      "key" TEXT,
      "contributorId" TEXT,
      "artifactPatronId" TEXT,
      "name" TEXT,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "syncInFlightStatus" INTEGER NOT NULL,
      "syncStatus" INTEGER NOT NULL,
      "email" STRING DEFAULT '',
      "phoneNumber" STRING DEFAULT '',
      "cisUserId" STRING DEFAULT '',
      PRIMARY KEY("localId")
    );

    CREATE TABLE "FSConversation" (
      "localId" TEXT PRIMARY KEY,
      "serverId" TEXT,
      "about" TEXT,
      "aboutUrl" TEXT,
      "lastModifiedTime" REAL NOT NULL,
      "msgCount" INTEGER NOT NULL,
      "unreadMsgCount" INTEGER NOT NULL,
      "subject" TEXT,
      "userConversationState" TEXT,
      "participantIds" BLOB,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "syncInFlightStatus" INTEGER NOT NULL,
      "syncStatus" INTEGER NOT NULL
    );

    CREATE TABLE "FSCouple" (
      "localId" TEXT PRIMARY KEY,
      "person1Pid" TEXT,
      "person2Pid" TEXT,
      "relationshipId" TEXT,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "syncInFlightStatus" INTEGER NOT NULL,
      "syncStatus" INTEGER NOT NULL,
      "sortKey" INTEGER NOT NULL DEFAULT 2147483647
    );

    CREATE TABLE "FSDescendants" (
      "localId" text,
      "descendantPids" text,
      "pid" text,
      "cacheHash" TEXT,
      "lastFetchDate" real NOT NULL,
      "syncInFlightStatus" integer NOT NULL,
      "syncStatus" integer NOT NULL,
      PRIMARY KEY("localId")
    );

    CREATE TABLE "FSFOR" (
      "localId" TEXT PRIMARY KEY,
      "id" TEXT,
      "createdOn" REAL NOT NULL,
      "path" TEXT,
      "title" TEXT
    );

    CREATE TABLE "FSFact" (
      "localId" TEXT,
      "factId" TEXT,
      "ownerEntityId" TEXT,
      "nameForms" blob,
      "date" blob,
      "place" blob,
      "type" integer NOT NULL,
      "serverType" text,
      "value" TEXT,
      "contributorId" text,
      "lastModified" REAL NOT NULL DEFAULT 0,
      "changeMessage" TEXT,
      "sortKey" INTEGER NOT NULL DEFAULT 2147483647,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "syncStatus" INTEGER NOT NULL,
      "syncInFlightStatus" INTEGER NOT NULL,
      PRIMARY KEY("localId")
    );

    CREATE TABLE "FSHintList" (
      "localId" TEXT PRIMARY KEY,
      "pid" TEXT,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "syncInFlightStatus" INTEGER NOT NULL,
      "syncStatus" INTEGER NOT NULL
    );

    CREATE TABLE "FSHistoryItem" (
      "localId" TEXT,
      "sequenceNumber" INTEGER NOT NULL,
      "pid" TEXT,
      "displayName" TEXT,
      "lifespan" TEXT,
      "genderRaw" INTEGER NOT NULL DEFAULT 0,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "syncInFlightStatus" INTEGER NOT NULL,
      "syncStatus" INTEGER NOT NULL,
      PRIMARY KEY("localId")
    );

    CREATE TABLE "FSHistoryList" (
      "localId" TEXT PRIMARY KEY,
      "pid" TEXT,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "syncInFlightStatus" INTEGER NOT NULL,
      "syncStatus" INTEGER NOT NULL
    );

    CREATE TABLE "FSMessage" (
      "localId" TEXT PRIMARY KEY,
      "serverId" TEXT,
      "conversationId" TEXT,
      "authorId" TEXT,
      "body" TEXT,
      "created" REAL NOT NULL,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "syncInFlightStatus" INTEGER NOT NULL,
      "syncStatus" INTEGER NOT NULL
    );

    CREATE TABLE "FSMyArtifacts" (
      "localId" TEXT PRIMARY KEY,
      "listType" INTEGER NOT NULL,
      "cacheHash" TEXT,
      "cisId" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "syncInFlightStatus" INTEGER NOT NULL,
      "syncStatus" INTEGER NOT NULL
    );

    CREATE TABLE "FSMyTaggedPersons" (
      "localId" TEXT PRIMARY KEY,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "syncInFlightStatus" INTEGER NOT NULL,
      "syncStatus" INTEGER NOT NULL
    );

    CREATE TABLE "FSParentChild" (
      "localId" TEXT,
      "relationshipId" TEXT,
      "childId" TEXT,
      "fatherId" TEXT,
      "motherId" TEXT,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "syncInFlightStatus" INTEGER NOT NULL,
      "syncStatus" INTEGER NOT NULL,
      "parentSortKey" INTEGER NOT NULL DEFAULT 0,
      "childSortKey" INTEGER NOT NULL DEFAULT 0,
      PRIMARY KEY("localId")
    );

    CREATE TABLE "FSPedigree" (
      "localId" TEXT PRIMARY KEY,
      "ancestorPids" TEXT,
      "pid" TEXT,
      "preferredSpousePid" TEXT,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "syncInFlightStatus" INTEGER NOT NULL,
      "syncStatus" INTEGER NOT NULL
    );

    CREATE TABLE "FSPersonArtifacts" (
      "localId" TEXT PRIMARY KEY,
      "pid" TEXT,
      "listType" INTEGER NOT NULL,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "syncInFlightStatus" INTEGER NOT NULL,
      "syncStatus" INTEGER NOT NULL
    );

    CREATE TABLE "FSPersonNote" (
      "localId" TEXT PRIMARY KEY,
      "serverId" TEXT,
      "pid" TEXT,
      "subject" TEXT,
      "text" TEXT,
      "contributorId" text,
      "lastModified" INTEGER NOT NULL DEFAULT 0,
      "changeMessage" TEXT,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "syncInFlightStatus" INTEGER NOT NULL,
      "syncStatus" INTEGER NOT NULL
    );

    CREATE TABLE "FSPersonNoteList" (
      "localId" TEXT PRIMARY KEY,
      "pid" TEXT,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "syncInFlightStatus" INTEGER NOT NULL,
      "syncStatus" INTEGER NOT NULL
    );

    CREATE TABLE "FSPersonPotentialPortrait" (
      "photoTagLocalId" TEXT PRIMARY KEY NOT NULL,
      "personLocalId" TEXT NOT NULL
    );

    CREATE TABLE "FSPersonVitals" (
      "localId" TEXT,
      "displayName" TEXT,
      "fullName" TEXT,
      "genderRaw" INTEGER,
      "givenName" TEXT,
      "lifespan" TEXT,
      "living" INTEGER NOT NULL DEFAULT 0,
      "pid" TEXT NOT NULL,
      "surName" TEXT,
      "preferredSpousePid" TEXT,
      "preferredParentsRelationshipId" TEXT,
      "sortKey" INTEGER NOT NULL DEFAULT 999999999,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "portraitArtifactLocalId" TEXT,
      "suffix" TEXT,
      "syncInFlightStatus" INTEGER NOT NULL,
      "syncStatus" INTEGER NOT NULL,
      PRIMARY KEY("localId")
    );

    CREATE TABLE "FSPersona" (
      "localId" TEXT PRIMARY KEY,
      "serverId" TEXT,
      "name" TEXT,
      "treePersonIds" BLOB,
      "photoTagServerId" TEXT DEFAULT NULL,
      "detachReason" TEXT DEFAULT NULL,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "syncInFlightStatus" INTEGER NOT NULL,
      "syncStatus" INTEGER NOT NULL
    );

    CREATE TABLE "FSPhotoTag" (
      "localId" TEXT PRIMARY KEY,
      "artifactLocalId" TEXT,
      "artifactServerId" TEXT,
      "deletable" INTEGER NOT NULL DEFAULT 0,
      "editable" INTEGER NOT NULL DEFAULT 0,
      "height" REAL NOT NULL DEFAULT 0,
      "serverId" TEXT,
      "softTag" INTEGER NOT NULL DEFAULT 0,
      "taggedPersonLocalId" TEXT,
      "taggedPersonServerId" TEXT,
      "title" TEXT,
      "width" REAL NOT NULL DEFAULT 0,
      "x" REAL NOT NULL DEFAULT 0,
      "y" REAL NOT NULL DEFAULT 0,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "syncInFlightStatus" INTEGER NOT NULL,
      "syncStatus" INTEGER NOT NULL,
      "personaLocalId" STRING DEFAULT NULL,
      "personaServerId" STRING DEFAULT NULL
    );

    CREATE TABLE "FSRecordHint" (
      "localId" TEXT PRIMARY KEY,
      "serverId" TEXT,
      "matchedId" TEXT,
      "sourceLinkUrl" TEXT,
      "pid" TEXT,
      "title" TEXT,
      "collectionType" TEXT,
      "personName" TEXT,
      "score" REAL NOT NULL DEFAULT 0,
      "published" REAL NOT NULL DEFAULT 0,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "syncInFlightStatus" INTEGER NOT NULL,
      "syncStatus" INTEGER NOT NULL
    );

    CREATE TABLE "FSRelationships" (
      "localId" TEXT PRIMARY KEY,
      "pid" TEXT,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "syncInFlightStatus" INTEGER NOT NULL,
      "syncStatus" INTEGER NOT NULL
    );

    CREATE TABLE "FSReservations" (
      "localId" TEXT PRIMARY KEY,
      "personReservationIds" BLOB,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "syncInFlightStatus" INTEGER NOT NULL,
      "syncStatus" INTEGER NOT NULL
    );

    CREATE TABLE "FSScopeOfInterest" (
      "localId" TEXT PRIMARY KEY,
      "pids" BLOB,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "syncInFlightStatus" INTEGER NOT NULL,
      "syncStatus" INTEGER NOT NULL
    );

    CREATE TABLE "FSSource" (
      "localId" TEXT PRIMARY KEY,
      "artifactLocalId" TEXT,
      "artifactServerId" TEXT,
      "serverId" TEXT,
      "title" TEXT,
      "url" TEXT,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "syncInFlightStatus" INTEGER NOT NULL,
      "syncStatus" INTEGER NOT NULL,
      "notes" TEXT DEFAULT '',
      "citation" TEXT DEFAULT '',
      "contributorCisId" TEXT DEFAULT '',
      "modifiedTimestamp" INTEGER NOT NULL DEFAULT 0,
      "resourceType" TEXT '',
      "changeMessage" TEXT ''
    );

    CREATE TABLE "FSSourceReference" (
      "localId" TEXT PRIMARY KEY,
      "pid" TEXT,
      "sourceLocalId" TEXT,
      "sourceReferenceServerId" TEXT,
      "changeMessage" TEXT,
      "contributorId" TEXT,
      "modifiedTimestamp" INTEGER NOT NULL DEFAULT 0,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "syncInFlightStatus" INTEGER NOT NULL,
      "syncStatus" INTEGER NOT NULL
    );

    CREATE TABLE "FSSourceReferenceList" (
      "localId" TEXT PRIMARY KEY,
      "pid" TEXT,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "syncInFlightStatus" INTEGER NOT NULL,
      "syncStatus" INTEGER NOT NULL
    );

    CREATE TABLE "FSTaggedPerson" (
      "localId" TEXT PRIMARY KEY,
      "name" TEXT,
      "pid" TEXT,
      "serverId" TEXT,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "portraitArtifactLocalId" TEXT,
      "syncInFlightStatus" INTEGER NOT NULL,
      "syncStatus" INTEGER NOT NULL,
      "myTaggedPersonsLocalId" TEXT,
      "didLinkToPidOnServer" INTEGER NOT NULL DEFAULT 0
    );

    CREATE TABLE "FSUser" (
      "localId" TEXT,
      "cisId" TEXT,
      "contactName" TEXT,
      "email" TEXT,
      "fullName" TEXT,
      "isMember" INTEGER NOT NULL DEFAULT 1,
      "pid" TEXT,
      "userId" TEXT,
      "username" TEXT,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "syncInFlightStatus" INTEGER NOT NULL,
      "syncStatus" INTEGER NOT NULL, helperPin STRING DEFAULT '', hasHelperPermission INTEGER NOT NULL DEFAULT 0,
      PRIMARY KEY("localId")
    );

    CREATE TABLE "FSWatch" (
      "localId" TEXT PRIMARY KEY,
      "pid" TEXT,
      "resourceId" TEXT,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "syncInFlightStatus" INTEGER NOT NULL,
      "syncStatus" INTEGER NOT NULL
    );

    CREATE TABLE "List_Artifact" (
      "listLocalId" TEXT,
      "listType" INTEGER,
      "artifactLocalId" TEXT,
      "artifactType" INTEGER
    );

    CREATE TABLE "Ordinance" (
      "localId" TEXT,
      "assignedToTemple" INTEGER NOT NULL,
      "bornInCovenant" INTEGER NOT NULL,
      "canPrint" INTEGER NOT NULL,
      "completedDate" TEXT,
      "completedPlace" TEXT,
      "fatherId" TEXT,
      "fatherName" TEXT,
      "motherId" TEXT,
      "motherName" TEXT,
      "reserve" INTEGER NOT NULL,
      "spouseId" TEXT,
      "status" INTEGER NOT NULL,
      "type" INTEGER NOT NULL,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "syncInFlightStatus" INTEGER NOT NULL,
      "syncStatus" INTEGER NOT NULL,
      "personReservationPid" TEXT,
      "whyNotQualifying" TEXT DEFAULT NULL,
      "ownerName" TEXT DEFAULT '',
      "reservedDate" TEXT DEFAULT '',
      "comparableReservedDate" TEXT DEFAULT '',
      "requiresPermission" INTEGER NOT NULL,
      "canAssign" INTEGER NOT NULL DEFAULT 0,
      "canTransfer" INTEGER NOT NULL DEFAULT 0,
      "canUnreserve" INTEGER NOT NULL DEFAULT 0,
      "shareBatchId" STRING DEFAULT '',
      "shareComparableExpireDate" STRING DEFAULT '',
      "shareShareExpireDate" STRING DEFAULT '',
      "shareReceiveUrl" STRING DEFAULT '',
      PRIMARY KEY("localId")
    );

    CREATE TABLE "PersonReservation" (
      "localId" TEXT,
      "displayName" TEXT,
      "gender" TEXT,
      "givenName" TEXT,
      "lifespan" TEXT,
      "pid" TEXT,
      "surName" TEXT,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "syncInFlightStatus" INTEGER NOT NULL,
      "syncStatus" INTEGER NOT NULL,
      "hasDuplicate" INTEGER NOT NULL DEFAULT 0,
      PRIMARY KEY("localId")
    );

    CREATE UNIQUE INDEX "INDEX_Artifact_Associations_unique" ON Artifact_Associations ("artifact1LocalId", "artifact2LocalId");
    CREATE UNIQUE INDEX "INDEX_List_Artifact_listId_artifactId" ON List_Artifact ("listLocalId", "artifactLocalId");

    CREATE UNIQUE INDEX "main"."INDEX_artifact_server" ON FSArtifact ("serverId");
    CREATE UNIQUE INDEX "main"."INDEX_conversation_server" ON FSConversation ("serverId");
    CREATE UNIQUE INDEX "main"."INDEX_contributor_server" ON FSContributor ("contributorId");
    CREATE UNIQUE INDEX "main"."INDEX_couple_server" ON FSCouple ("relationshipId");
    CREATE UNIQUE INDEX "main"."INDEX_descendants_server" ON FSDescendants ("pid");
    CREATE UNIQUE INDEX "main"."INDEX_fact_server" ON FSFact ("factId", "ownerEntityId");
    CREATE UNIQUE INDEX "main"."INDEX_hintList_server" ON FSHintList ("pid");
    CREATE UNIQUE INDEX "main"."INDEX_message_server" ON FSMessage ("serverId");
    CREATE UNIQUE INDEX "main"."INDEX_parentChild_server" ON FSParentChild ("relationshipId");
    CREATE UNIQUE INDEX "main"."INDEX_pedigree_server" ON FSPedigree ("pid", "preferredSpousePid");
    CREATE UNIQUE INDEX "main"."INDEX_persona_server" ON FSPersona ("serverId");
    CREATE UNIQUE INDEX "main"."INDEX_personArtifacts_server" ON FSPersonArtifacts ("pid");
    CREATE UNIQUE INDEX "main"."INDEX_note_server" ON FSPersonNote ("serverId");
    CREATE UNIQUE INDEX "main"."INDEX_noteList_server" ON FSPersonNoteList ("pid");
    CREATE UNIQUE INDEX "main"."INDEX_person_server" ON FSPersonVitals ("pid");
    CREATE UNIQUE INDEX "main"."INDEX_photoTag_server" ON FSPhotoTag ("serverId");
    CREATE UNIQUE INDEX "main"."INDEX_recordHint_server" ON FSRecordHint ("serverId");
    CREATE UNIQUE INDEX "main"."INDEX_relationship_server" ON FSRelationships ("pid");
    CREATE UNIQUE INDEX "main"."INDEX_source_server" ON FSSource ("serverId");
    CREATE UNIQUE INDEX "main"."INDEX_sourceReference_server" ON FSSourceReference ("sourceReferenceServerId");
    CREATE UNIQUE INDEX "main"."INDEX_sourceReferenceList_server" ON FSSourceReferenceList ("pid");
    CREATE UNIQUE INDEX "main"."INDEX_taggedPerson_server" ON FSTaggedPerson ("serverId");
    CREATE UNIQUE INDEX "main"."INDEX_watch_server" ON FSWatch ("pid");
    CREATE UNIQUE INDEX "main"."INDEX_ordinance_server" ON Ordinance ("type", "personReservationPid");
    CREATE UNIQUE INDEX "main"."INDEX_personReservation_server" ON PersonReservation ("pid");
    """,

    """
    ALTER TABLE "main"."FSUser" RENAME TO "_FSUser_old_20170208";

    CREATE TABLE "main"."FSUser" (
    "localId" TEXT,
    "cisId" TEXT,
    "contactName" TEXT,
    "email" TEXT,
    "fullName" TEXT,
    "isMember" INTEGER NOT NULL DEFAULT 1,
    "pid" TEXT,
    "userId" TEXT,
    "username" TEXT,
    "cacheHash" TEXT,
    "lastFetchDate" REAL NOT NULL,
    "syncInFlightStatus" INTEGER NOT NULL,
    "syncStatus" INTEGER NOT NULL,
    "helperPin" TEXT DEFAULT '',
    "hasHelperPermission" INTEGER NOT NULL DEFAULT 0,
    PRIMARY KEY("localId")
    );

    INSERT INTO "main"."FSUser" ("localId", "cisId", "contactName", "email", "fullName", "isMember", "pid", "userId", "username", "cacheHash", "lastFetchDate", "syncInFlightStatus", "syncStatus", "hasHelperPermission" ) SELECT "localId", "cisId", "contactName", "email", "fullName", "isMember", "pid", "userId", "username", "cacheHash", "lastFetchDate", "syncInFlightStatus", "syncStatus", "hasHelperPermission" FROM "main"."_FSUser_old_20170208";

    DROP TABLE _FSUser_old_20170208;
    """,

    """
    ALTER TABLE FSPhotoTag ADD taggedPersonPid STRING DEFAULT '';
    """,

    """
    CREATE TABLE "PersonTasksList" (
    "localId" TEXT PRIMARY KEY,
    "listKeyRaw" TEXT NOT NULL,
    "numGens" INTEGER,
    "cacheHash" TEXT,
    "lastFetchDate" REAL NOT NULL,
    "syncInFlightStatus" INTEGER NOT NULL,
    "syncStatus" INTEGER NOT NULL
    );

    CREATE TABLE "PersonTasks" (
    "localId" TEXT PRIMARY KEY,
    "listKeyRaw" TEXT NOT NULL,
    "pid" TEXT NOT NULL,
    "sortKey" INTEGER NOT NULL,
    "hasHints" INTEGER NOT NULL,
    "templeStatusRaw" INTEGER NOT NULL,
    "displayName" TEXT NOT NULL,
    "genderRaw" INTEGER NOT NULL,
    "lifespan" TEXT,
    "living" INTEGER NOT NULL,
    "cacheHash" TEXT,
    "lastFetchDate" REAL NOT NULL,
    "syncInFlightStatus" INTEGER NOT NULL,
    "syncStatus" INTEGER NOT NULL
    );

    CREATE UNIQUE INDEX "main"."INDEX_personTasksList_listKey" ON PersonTasksList ("listKeyRaw");
    CREATE UNIQUE INDEX "main"."INDEX_personTasks_listKey_pid" ON PersonTasks ("listKeyRaw", "pid");
    """,

    """
    ALTER TABLE FSFact ADD placeId text DEFAULT NULL;

    CREATE TABLE "Place" (
      "id" text NOT NULL,
      "latitude" real,
      "longitude" real,
      "name" text NOT NULL,
      PRIMARY KEY("id")
    );
    """,

    """
    ALTER TABLE FSSourceReference ADD sortKey STRING NOT NULL DEFAULT '';
    """,

    """
    DROP INDEX "INDEX_ordinance_server";
    CREATE UNIQUE INDEX "INDEX_ordinance_server" ON Ordinance ("type", "personReservationPid", "fatherId", "motherId", "spouseId");
    """,

    """
    ALTER TABLE FSArtifact ADD serverHash TEXT DEFAULT '';
    """,

    """
    CREATE TABLE "Album" (
    "localId" TEXT PRIMARY KEY,
    "serverId" TEXT,
    "listType" INTEGER NOT NULL,
    "albumName" TEXT,
    "albumDescription" TEXT,
    "contributorPatronId" INTEGER NOT NULL,
    "uploaderId" INTEGER NOT NULL,
    "creationDateTime" INTEGER NOT NULL,
    "restrictionState" TEXT NOT NULL,
    "artifactCount" INTEGER NOT NULL,
    "thumbUrl" TEXT,
    "thumbSquareUrl" TEXT,
    "thumbIconUrl" TEXT,
    "seoIndexable" INTEGER NOT NULL,
    "favorite" INTEGER NOT NULL,
    "editableByCaller" INTEGER NOT NULL,
    "cacheHash" TEXT,
    "lastFetchDate" REAL NOT NULL,
    "syncInFlightStatus" INTEGER NOT NULL,
    "syncStatus" INTEGER NOT NULL
    );

    CREATE UNIQUE INDEX "main"."INDEX_album_server" ON Album ("serverId");

    CREATE TABLE "MyAlbumsList" (
    "localId" TEXT PRIMARY KEY,
    "cacheHash" TEXT,
    "lastFetchDate" REAL NOT NULL,
    "syncInFlightStatus" INTEGER NOT NULL,
    "syncStatus" INTEGER NOT NULL
    );

    ALTER TABLE FSArtifact ADD archived INTEGER NOT NULL DEFAULT 0;
    """,

    """
    DROP TABLE FSScopeOfInterest;

    CREATE TABLE "ScopeAncestor" (
    "localId" TEXT PRIMARY KEY,
    "scopeTypeRaw" TEXT NOT NULL,
    "pid" TEXT NOT NULL,
    "cacheHash" TEXT,
    "lastFetchDate" REAL NOT NULL,
    "syncInFlightStatus" INTEGER NOT NULL,
    "syncStatus" INTEGER NOT NULL
    );

    CREATE UNIQUE INDEX "main"."INDEX_ScopeAncestor_scopeTypeRaw_pid" ON ScopeAncestor ("scopeTypeRaw", "pid");
    """,

    """
    CREATE TABLE "PedigreePreferences" (
    "localId" TEXT PRIMARY KEY,
    "pid" TEXT NOT NULL,
    "preferredCoupleId" TEXT,
    "preferredParentChildId" TEXT,
    "preferredCoparentParentChildId" TEXT,
    "cacheHash" TEXT,
    "lastFetchDate" REAL NOT NULL,
    "syncInFlightStatus" INTEGER NOT NULL,
    "syncStatus" INTEGER NOT NULL
    );

    CREATE UNIQUE INDEX "main"."INDEX_PedigreePreferences_pid" ON PedigreePreferences ("pid");
    """,

    """
    /* */
    /* Update tables to not use "raw" in names of enum property stores and remove unused columns */
    /* */

    /* Album */
    ALTER TABLE "main"."Album" RENAME TO "_Album_old_20171023";
    DROP INDEX "main"."INDEX_album_server";

    CREATE TABLE "main"."Album" (
      "localId" TEXT,
      "serverId" TEXT,
      "listType" INTEGER NOT NULL,
      "albumName" TEXT,
      "albumDescription" TEXT,
      "contributorPatronId" INTEGER NOT NULL,
      "uploaderId" INTEGER NOT NULL,
      "creationDateTime" INTEGER NOT NULL,
      "restrictionState" TEXT NOT NULL,
      "artifactCount" INTEGER NOT NULL,
      "thumbUrl" TEXT,
      "thumbSquareUrl" TEXT,
      "thumbIconUrl" TEXT,
      "seoIndexable" INTEGER NOT NULL,
      "favorite" INTEGER NOT NULL,
      "editableByCaller" INTEGER NOT NULL,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      PRIMARY KEY("localId")
    );

    INSERT INTO "main"."Album" ("localId", "serverId", "listType", "albumName", "albumDescription", "contributorPatronId", "uploaderId", "creationDateTime", "restrictionState", "artifactCount", "thumbUrl", "thumbSquareUrl", "thumbIconUrl", "seoIndexable", "favorite", "editableByCaller", "cacheHash", "lastFetchDate") SELECT "localId", "serverId", "listType", "albumName", "albumDescription", "contributorPatronId", "uploaderId", "creationDateTime", "restrictionState", "artifactCount", "thumbUrl", "thumbSquareUrl", "thumbIconUrl", "seoIndexable", "favorite", "editableByCaller", "cacheHash", "lastFetchDate" FROM "main"."_Album_old_20171023";
    CREATE UNIQUE INDEX "main"."INDEX_album_server" ON Album ("serverId" ASC);
    DROP TABLE _Album_old_20171023;


    /* Contributor */
    ALTER TABLE "main"."FSContributor" RENAME TO "_FSContributor_old_20171023";
    DROP INDEX "main"."INDEX_contributor_server";

    CREATE TABLE "main"."FSContributor" (
      "localId" TEXT NOT NULL,
      "key" TEXT,
      "contributorId" TEXT,
      "artifactPatronId" TEXT,
      "name" TEXT,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "email" STRING DEFAULT '',
      "phoneNumber" STRING DEFAULT '',
      "cisUserId" STRING DEFAULT '',
      PRIMARY KEY("localId")
    );

    INSERT INTO "main"."FSContributor" ("localId", "key", "contributorId", "artifactPatronId", "name", "cacheHash", "lastFetchDate", "email", "phoneNumber", "cisUserId") SELECT "localId", "key", "contributorId", "artifactPatronId", "name", "cacheHash", "lastFetchDate", "email", "phoneNumber", "cisUserId" FROM "main"."_FSContributor_old_20171023";
    CREATE UNIQUE INDEX "main"."INDEX_contributor_server" ON FSContributor ("contributorId" ASC);
    DROP TABLE _FSContributor_old_20171023;


    /* Couple */
    ALTER TABLE "main"."FSCouple" RENAME TO "_FSCouple_old_20171023";
    DROP INDEX "main"."INDEX_couple_server";

    CREATE TABLE "main"."FSCouple" (
      "localId" TEXT,
      "person1Pid" TEXT,
      "person2Pid" TEXT,
      "relationshipId" TEXT,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "sortKey" INTEGER NOT NULL DEFAULT 2147483647,
      PRIMARY KEY("localId")
    );

    INSERT INTO "main"."FSCouple" ("localId", "person1Pid", "person2Pid", "relationshipId", "cacheHash", "lastFetchDate", "sortKey") SELECT "localId", "person1Pid", "person2Pid", "relationshipId", "cacheHash", "lastFetchDate", "sortKey" FROM "main"."_FSCouple_old_20171023";
    CREATE UNIQUE INDEX "main"."INDEX_couple_server" ON FSCouple ("relationshipId" ASC);
    DROP TABLE _FSCouple_old_20171023;

    /* Descendants */
    ALTER TABLE "main"."FSDescendants" RENAME TO "_FSDescendants_old_20171023";
    DROP INDEX "main"."INDEX_descendants_server";

    CREATE TABLE "main"."FSDescendants" (
      "localId" text,
      "descendantPids" text,
      "pid" text,
      "cacheHash" TEXT,
      "lastFetchDate" real NOT NULL,
      PRIMARY KEY("localId")
    );

    INSERT INTO "main"."FSDescendants" ("localId", "descendantPids", "pid", "cacheHash", "lastFetchDate") SELECT "localId", "descendantPids", "pid", "cacheHash", "lastFetchDate" FROM "main"."_FSDescendants_old_20171023";
    CREATE UNIQUE INDEX "main"."INDEX_descendants_server" ON FSDescendants ("pid" ASC);
    DROP TABLE _FSDescendants_old_20171023;


    /* DataHint */
    ALTER TABLE "main"."DataHint" RENAME TO "_DataHint_old_20171023";

    CREATE TABLE "main"."DataHint" (
      "localId" TEXT,
      "pid" TEXT,
      "category" TEXT,
      "type" TEXT,
      "contextRaw" TEXT,
      "canBeDismissed" INTEGER NOT NULL DEFAULT 0,
      "entityId" TEXT,
      "contextId" TEXT,
      "sortKey" INTEGER,
      PRIMARY KEY("localId")
    );

    INSERT INTO "main"."DataHint" ("localId", "pid", "category", "type", "contextRaw", "canBeDismissed", "entityId", "contextId", "sortKey") SELECT "localId", "pid", "categoryRaw", "typeRaw", "contextRaw", "canBeDismissed", "entityId", "contextId", "sortKey" FROM "main"."_DataHint_old_20171023";
    DROP TABLE _DataHint_old_20171023;


    /* Artifact */
    ALTER TABLE "main"."FSArtifact" RENAME TO "_FSArtifact_old_20171023";
    DROP INDEX "main"."INDEX_artifact_server";

    CREATE TABLE "main"."FSArtifact" (
      "localId" TEXT,
      "serverId" TEXT,
      "type" INTEGER NOT NULL DEFAULT 6,
      "url" TEXT,
      "thumbUrl" TEXT,
      "desc" TEXT,
      "title" TEXT,
      "mimeType" TEXT,
      "restricted" INTEGER NOT NULL,
      "editableByCaller" INTEGER NOT NULL,
      "category" TEXT,
      "contentCategory" TEXT,
      "uploadedOn" REAL NOT NULL,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "syncInFlightStatus" INTEGER NOT NULL,
      "syncStatus" INTEGER NOT NULL,
      "duration" INTEGER NOT NULL DEFAULT 0,
      "height" INTEGER NOT NULL DEFAULT 0,
      "width" INTEGER NOT NULL DEFAULT 0,
      "size" INTEGER NOT NULL DEFAULT 0,
      "fullText" TEXT,
      "artifactPatronId" TEXT DEFAULT NULL,
      "deepZoomLiteUrl" TEXT DEFAULT NULL,
      "portraitPhotoTagLocalId" TEXT,
      "serverHash" TEXT DEFAULT '',
      "archived" INTEGER NOT NULL DEFAULT 0,
      PRIMARY KEY("localId")
    );

    INSERT INTO "main"."FSArtifact" ("localId", "serverId", "type", "url", "thumbUrl", "desc", "title", "mimeType", "restricted", "editableByCaller", "category", "contentCategory", "uploadedOn", "cacheHash", "lastFetchDate", "syncInFlightStatus", "syncStatus", "duration", "height", "width", "size", "fullText", "artifactPatronId", "deepZoomLiteUrl", "portraitPhotoTagLocalId", "serverHash", "archived") SELECT "localId", "serverId", "typeRaw", "url", "thumbUrl", "desc", "title", "mimeType", "restricted", "editableByCaller", "category", "contentCategory", "uploadedOn", "cacheHash", "lastFetchDate", "syncInFlightStatus", "syncStatus", "duration", "height", "width", "size", "fullText", "artifactPatronId", "deepZoomLiteUrl", "portraitPhotoTagLocalId", "serverHash", "archived" FROM "main"."_FSArtifact_old_20171023";
    CREATE UNIQUE INDEX "main"."INDEX_artifact_server" ON FSArtifact ("serverId" ASC);
    DROP TABLE _FSArtifact_old_20171023;

    /* FSHistoryItem */
    ALTER TABLE "main"."FSHistoryItem" RENAME TO "_FSHistoryItem_old_20171023";

    CREATE TABLE "main"."FSHistoryItem" (
      "localId" TEXT,
      "sequenceNumber" INTEGER NOT NULL,
      "pid" TEXT,
      "displayName" TEXT,
      "lifespan" TEXT,
      "gender" INTEGER NOT NULL DEFAULT 0,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      PRIMARY KEY("localId")
    );

    INSERT INTO "main"."FSHistoryItem" ("localId", "sequenceNumber", "pid", "displayName", "lifespan", "gender", "cacheHash", "lastFetchDate") SELECT "localId", "sequenceNumber", "pid", "displayName", "lifespan", "genderRaw", "cacheHash", "lastFetchDate" FROM "main"."_FSHistoryItem_old_20171023";
    DROP TABLE _FSHistoryItem_old_20171023;

    /* Person */
    ALTER TABLE "main"."FSPersonVitals" RENAME TO "_FSPersonVitals_old_20171023";
    DROP INDEX "main"."INDEX_person_server";

    CREATE TABLE "main"."FSPersonVitals" (
      "localId" TEXT,
      "displayName" TEXT,
      "fullName" TEXT,
      "gender" INTEGER,
      "givenName" TEXT,
      "lifespan" TEXT,
      "living" INTEGER NOT NULL DEFAULT 0,
      "pid" TEXT NOT NULL,
      "surName" TEXT,
      "preferredSpousePid" TEXT,
      "preferredParentsRelationshipId" TEXT,
      "sortKey" INTEGER NOT NULL DEFAULT 999999999,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "portraitArtifactLocalId" TEXT,
      "suffix" TEXT,
      PRIMARY KEY("localId")
    );

    INSERT INTO "main"."FSPersonVitals" ("localId", "displayName", "fullName", "gender", "givenName", "lifespan", "living", "pid", "surName", "preferredSpousePid", "preferredParentsRelationshipId", "sortKey", "cacheHash", "lastFetchDate", "portraitArtifactLocalId", "suffix") SELECT "localId", "displayName", "fullName", "genderRaw", "givenName", "lifespan", "living", "pid", "surName", "preferredSpousePid", "preferredParentsRelationshipId", "sortKey", "cacheHash", "lastFetchDate", "portraitArtifactLocalId", "suffix" FROM "main"."_FSPersonVitals_old_20171023";
    CREATE UNIQUE INDEX "main"."INDEX_person_server" ON FSPersonVitals ("pid" ASC);
    DROP TABLE _FSPersonVitals_old_20171023;


    /* ScopeAncestor */
    ALTER TABLE "main"."ScopeAncestor" RENAME TO "_ScopeAncestor_old_20171023";
    DROP INDEX "main"."INDEX_ScopeAncestor_scopeTypeRaw_pid";

    CREATE TABLE "main"."ScopeAncestor" (
      "localId" TEXT,
      "scopeType" TEXT NOT NULL,
      "pid" TEXT NOT NULL,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      PRIMARY KEY("localId")
    );

    INSERT INTO "main"."ScopeAncestor" ("localId", "scopeType", "pid", "cacheHash", "lastFetchDate") SELECT "localId", "scopeTypeRaw", "pid", "cacheHash", "lastFetchDate" FROM "main"."_ScopeAncestor_old_20171023";
    CREATE UNIQUE INDEX "main"."INDEX_ScopeAncestor_scopeType_pid" ON ScopeAncestor ("scopeType" ASC, "pid" ASC);
    DROP TABLE _ScopeAncestor_old_20171023;

    /* Fact */
    ALTER TABLE "main"."FSFact" RENAME TO "_FSFact_old_20171023";
    DROP INDEX "main"."INDEX_fact_server";

    CREATE TABLE "main"."FSFact" (
      "localId" TEXT,
      "factId" TEXT,
      "ownerEntityId" TEXT,
      "nameData" blob,
      "dateData" blob,
      "placeData" blob,
      "type" integer NOT NULL,
      "serverType" text,
      "value" TEXT,
      "contributorId" text,
      "lastModified" REAL NOT NULL DEFAULT 0,
      "changeMessage" TEXT,
      "sortKey" INTEGER NOT NULL DEFAULT 2147483647,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "placeId" text DEFAULT NULL,
      PRIMARY KEY("localId")
    );

    INSERT INTO "main"."FSFact" ("localId", "factId", "ownerEntityId", "nameData", "dateData", "placeData", "type", "serverType", "value", "contributorId", "lastModified", "changeMessage", "sortKey", "cacheHash", "lastFetchDate", "placeId") SELECT "localId", "factId", "ownerEntityId", "nameForms", "date", "place", "type", "serverType", "value", "contributorId", "lastModified", "changeMessage", "sortKey", "cacheHash", "lastFetchDate", "placeId" FROM "main"."_FSFact_old_20171023";
    CREATE UNIQUE INDEX "main"."INDEX_fact_server" ON FSFact ("factId" ASC, "ownerEntityId" ASC);
    DROP TABLE _FSFact_old_20171023;


    /* HintList */
    ALTER TABLE "main"."FSHintList" RENAME TO "_FSHintList_old_20171023";
    DROP INDEX "main"."INDEX_hintList_server";

    CREATE TABLE "main"."FSHintList" (
      "localId" TEXT,
      "pid" TEXT,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      PRIMARY KEY("localId")
    );

    INSERT INTO "main"."FSHintList" ("localId", "pid", "cacheHash", "lastFetchDate") SELECT "localId", "pid", "cacheHash", "lastFetchDate" FROM "main"."_FSHintList_old_20171023";
    CREATE UNIQUE INDEX "main"."INDEX_hintList_server" ON FSHintList ("pid" ASC);
    DROP TABLE _FSHintList_old_20171023;


    /* HistoryItem */
    ALTER TABLE "main"."FSHistoryItem" RENAME TO "_FSHistoryItem_old_20171023";

    CREATE TABLE "main"."FSHistoryItem" (
      "localId" TEXT,
      "sequenceNumber" INTEGER NOT NULL,
      "pid" TEXT,
      "displayName" TEXT,
      "lifespan" TEXT,
      "gender" INTEGER NOT NULL DEFAULT 0,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      PRIMARY KEY("localId")
    );

    INSERT INTO "main"."FSHistoryItem" ("localId", "sequenceNumber", "pid", "displayName", "lifespan", "gender", "cacheHash", "lastFetchDate") SELECT "localId", "sequenceNumber", "pid", "displayName", "lifespan", "genderRaw", "cacheHash", "lastFetchDate" FROM "main"."_FSHistoryItem_old_20171023";
    DROP TABLE _FSHistoryItem_old_20171023;


    /* User */
    ALTER TABLE "main"."FSUser" RENAME TO "_FSUser_old_20171023";

    CREATE TABLE "main"."FSUser" (
      "localId" TEXT,
      "cisId" TEXT,
      "contactName" TEXT,
      "email" TEXT,
      "fullName" TEXT,
      "isMember" INTEGER NOT NULL DEFAULT 1,
      "pid" TEXT,
      "userId" TEXT,
      "username" TEXT,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "helperPin" TEXT DEFAULT '',
      "hasHelperPermission" INTEGER NOT NULL DEFAULT 0,
      PRIMARY KEY("localId")
    );

    INSERT INTO "main"."FSUser" ("localId", "cisId", "contactName", "email", "fullName", "isMember", "pid", "userId", "username", "cacheHash", "lastFetchDate", "helperPin", "hasHelperPermission") SELECT "localId", "cisId", "contactName", "email", "fullName", "isMember", "pid", "userId", "username", "cacheHash", "lastFetchDate", "helperPin", "hasHelperPermission" FROM "main"."_FSUser_old_20171023";
    DROP TABLE _FSUser_old_20171023;


    /* HistoryList */
    ALTER TABLE "main"."FSHistoryList" RENAME TO "_FSHistoryList_old_20171023";

    CREATE TABLE "main"."FSHistoryList" (
      "localId" TEXT,
      "pid" TEXT,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      PRIMARY KEY("localId")
    );

    INSERT INTO "main"."FSHistoryList" ("localId", "pid", "cacheHash", "lastFetchDate") SELECT "localId", "pid", "cacheHash", "lastFetchDate" FROM "main"."_FSHistoryList_old_20171023";
    DROP TABLE _FSHistoryList_old_20171023;


    /* MyArtifacts */
    ALTER TABLE "main"."FSMyArtifacts" RENAME TO "_FSMyArtifacts_old_20171023";

    CREATE TABLE "main"."FSMyArtifacts" (
      "localId" TEXT,
      "listType" INTEGER NOT NULL,
      "cacheHash" TEXT,
      "cisId" TEXT,
      "lastFetchDate" REAL NOT NULL,
      PRIMARY KEY("localId")
    );

    INSERT INTO "main"."FSMyArtifacts" ("localId", "listType", "cacheHash", "cisId", "lastFetchDate") SELECT "localId", "listType", "cacheHash", "cisId", "lastFetchDate" FROM "main"."_FSMyArtifacts_old_20171023";
    DROP TABLE _FSMyArtifacts_old_20171023;


    /* ParentChild */
    ALTER TABLE "main"."FSParentChild" RENAME TO "_FSParentChild_old_20171023";
    DROP INDEX "main"."INDEX_parentChild_server";

    CREATE TABLE "main"."FSParentChild" (
      "localId" TEXT,
      "relationshipId" TEXT,
      "childId" TEXT,
      "fatherId" TEXT,
      "motherId" TEXT,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "parentSortKey" INTEGER NOT NULL DEFAULT 0,
      "childSortKey" INTEGER NOT NULL DEFAULT 0,
      PRIMARY KEY("localId")
    );

    INSERT INTO "main"."FSParentChild" ("localId", "relationshipId", "childId", "fatherId", "motherId", "cacheHash", "lastFetchDate", "parentSortKey", "childSortKey") SELECT "localId", "relationshipId", "childId", "fatherId", "motherId", "cacheHash", "lastFetchDate", "parentSortKey", "childSortKey" FROM "main"."_FSParentChild_old_20171023";
    CREATE UNIQUE INDEX "main"."INDEX_parentChild_server" ON FSParentChild ("relationshipId" ASC);
    DROP TABLE _FSParentChild_old_20171023;


    /* Pedigree */
    ALTER TABLE "main"."FSPedigree" RENAME TO "_FSPedigree_old_20171023";
    DROP INDEX "main"."INDEX_pedigree_server";

    CREATE TABLE "main"."FSPedigree" (
      "localId" TEXT,
      "ancestorPids" TEXT,
      "pid" TEXT,
      "preferredSpousePid" TEXT,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      PRIMARY KEY("localId")
    );

    INSERT INTO "main"."FSPedigree" ("localId", "ancestorPids", "pid", "preferredSpousePid", "cacheHash", "lastFetchDate") SELECT "localId", "ancestorPids", "pid", "preferredSpousePid", "cacheHash", "lastFetchDate" FROM "main"."_FSPedigree_old_20171023";
    CREATE UNIQUE INDEX "main"."INDEX_pedigree_server" ON FSPedigree ("pid" ASC, "preferredSpousePid" ASC);
    DROP TABLE _FSPedigree_old_20171023;


    /* Person Artifacts */
    ALTER TABLE "main"."FSPersonArtifacts" RENAME TO "_FSPersonArtifacts_old_20171023";
    DROP INDEX "main"."INDEX_personArtifacts_server";

    CREATE TABLE "main"."FSPersonArtifacts" (
      "localId" TEXT,
      "pid" TEXT,
      "listType" INTEGER NOT NULL,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      PRIMARY KEY("localId")
    );

    INSERT INTO "main"."FSPersonArtifacts" ("localId", "pid", "listType", "cacheHash", "lastFetchDate") SELECT "localId", "pid", "listType", "cacheHash", "lastFetchDate" FROM "main"."_FSPersonArtifacts_old_20171023";
    CREATE UNIQUE INDEX "main"."INDEX_personArtifacts_server" ON FSPersonArtifacts ("pid" ASC);
    DROP TABLE _FSPersonArtifacts_old_20171023;


    /* PersonNote */
    ALTER TABLE "main"."FSPersonNote" RENAME TO "_FSPersonNote_old_20171023";
    DROP INDEX "main"."INDEX_note_server";

    CREATE TABLE "main"."FSPersonNote" (
      "localId" TEXT,
      "serverId" TEXT,
      "pid" TEXT,
      "subject" TEXT,
      "text" TEXT,
      "contributorId" text,
      "lastModified" INTEGER NOT NULL DEFAULT 0,
      "changeMessage" TEXT,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      PRIMARY KEY("localId")
    );

    INSERT INTO "main"."FSPersonNote" ("localId", "serverId", "pid", "subject", "text", "contributorId", "lastModified", "changeMessage", "cacheHash", "lastFetchDate") SELECT "localId", "serverId", "pid", "subject", "text", "contributorId", "lastModified", "changeMessage", "cacheHash", "lastFetchDate" FROM "main"."_FSPersonNote_old_20171023";
    CREATE UNIQUE INDEX "main"."INDEX_note_server" ON FSPersonNote ("serverId" ASC);
    DROP TABLE _FSPersonNote_old_20171023;


    /* PersonNoteList */
    ALTER TABLE "main"."FSPersonNoteList" RENAME TO "_FSPersonNoteList_old_20171023";
    DROP INDEX "main"."INDEX_noteList_server";

    CREATE TABLE "main"."FSPersonNoteList" (
      "localId" TEXT,
      "pid" TEXT,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      PRIMARY KEY("localId")
    );

    INSERT INTO "main"."FSPersonNoteList" ("localId", "pid", "cacheHash", "lastFetchDate") SELECT "localId", "pid", "cacheHash", "lastFetchDate" FROM "main"."_FSPersonNoteList_old_20171023";
    CREATE UNIQUE INDEX "main"."INDEX_noteList_server" ON FSPersonNoteList ("pid" ASC);
    DROP TABLE _FSPersonNoteList_old_20171023;


    /* RecordHint */
    ALTER TABLE "main"."FSRecordHint" RENAME TO "_FSRecordHint_old_20171023";
    DROP INDEX "main"."INDEX_recordHint_server";

    CREATE TABLE "main"."FSRecordHint" (
      "localId" TEXT,
      "serverId" TEXT,
      "matchedId" TEXT,
      "sourceLinkUrl" TEXT,
      "pid" TEXT,
      "title" TEXT,
      "collectionType" TEXT,
      "personName" TEXT,
      "score" REAL NOT NULL DEFAULT 0,
      "published" REAL NOT NULL DEFAULT 0,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      PRIMARY KEY("localId")
    );

    INSERT INTO "main"."FSRecordHint" ("localId", "serverId", "matchedId", "sourceLinkUrl", "pid", "title", "collectionType", "personName", "score", "published", "cacheHash", "lastFetchDate") SELECT "localId", "serverId", "matchedId", "sourceLinkUrl", "pid", "title", "collectionType", "personName", "score", "published", "cacheHash", "lastFetchDate" FROM "main"."_FSRecordHint_old_20171023";
    CREATE UNIQUE INDEX "main"."INDEX_recordHint_server" ON FSRecordHint ("serverId" ASC);
    DROP TABLE _FSRecordHint_old_20171023;


    /* Relationships */
    ALTER TABLE "main"."FSRelationships" RENAME TO "_FSRelationships_old_20171023";
    DROP INDEX "main"."INDEX_relationship_server";

    CREATE TABLE "main"."FSRelationships" (
      "localId" TEXT,
      "pid" TEXT,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      PRIMARY KEY("localId")
    );

    INSERT INTO "main"."FSRelationships" ("localId", "pid", "cacheHash", "lastFetchDate") SELECT "localId", "pid", "cacheHash", "lastFetchDate" FROM "main"."_FSRelationships_old_20171023";
    CREATE UNIQUE INDEX "main"."INDEX_relationship_server" ON FSRelationships ("pid" ASC);
    DROP TABLE _FSRelationships_old_20171023;


    /* Reservations */
    ALTER TABLE "main"."FSReservations" RENAME TO "_FSReservations_old_20171023";

    CREATE TABLE "main"."FSReservations" (
      "localId" TEXT,
      "personReservationIds" BLOB,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      PRIMARY KEY("localId")
    );

    INSERT INTO "main"."FSReservations" ("localId", "personReservationIds", "cacheHash", "lastFetchDate") SELECT "localId", "personReservationIds", "cacheHash", "lastFetchDate" FROM "main"."_FSReservations_old_20171023";
    DROP TABLE _FSReservations_old_20171023;


    /* MyAlbumList */
    ALTER TABLE "main"."MyAlbumsList" RENAME TO "_MyAlbumsList_old_20171023";

    CREATE TABLE "main"."MyAlbumsList" (
      "localId" TEXT,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      PRIMARY KEY("localId")
    );

    INSERT INTO "main"."MyAlbumsList" ("localId", "cacheHash", "lastFetchDate") SELECT "localId", "cacheHash", "lastFetchDate" FROM "main"."_MyAlbumsList_old_20171023";
    DROP TABLE _MyAlbumsList_old_20171023;


    /* Ordinance */
    ALTER TABLE "main"."Ordinance" RENAME TO "_Ordinance_old_20171023";
    DROP INDEX "main"."INDEX_ordinance_server";

    CREATE TABLE "main"."Ordinance" (
      "localId" TEXT,
      "assignedToTemple" INTEGER NOT NULL,
      "bornInCovenant" INTEGER NOT NULL,
      "canPrint" INTEGER NOT NULL,
      "completedDate" TEXT,
      "completedPlace" TEXT,
      "fatherId" TEXT,
      "fatherName" TEXT,
      "motherId" TEXT,
      "motherName" TEXT,
      "reserve" INTEGER NOT NULL,
      "spouseId" TEXT,
      "status" INTEGER NOT NULL,
      "type" INTEGER NOT NULL,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "personReservationPid" TEXT,
      "whyNotQualifying" TEXT DEFAULT NULL,
      "ownerName" TEXT DEFAULT '',
      "reservedDate" TEXT DEFAULT '',
      "comparableReservedDate" TEXT DEFAULT '',
      "requiresPermission" INTEGER NOT NULL,
      "canAssign" INTEGER NOT NULL DEFAULT 0,
      "canTransfer" INTEGER NOT NULL DEFAULT 0,
      "canUnreserve" INTEGER NOT NULL DEFAULT 0,
      "shareBatchId" STRING DEFAULT '',
      "shareComparableExpireDate" STRING DEFAULT '',
      "shareShareExpireDate" STRING DEFAULT '',
      "shareReceiveUrl" STRING DEFAULT '',
      PRIMARY KEY("localId")
    );

    INSERT INTO "main"."Ordinance" ("localId", "assignedToTemple", "bornInCovenant", "canPrint", "completedDate", "completedPlace", "fatherId", "fatherName", "motherId", "motherName", "reserve", "spouseId", "status", "type", "cacheHash", "lastFetchDate", "personReservationPid", "whyNotQualifying", "ownerName", "reservedDate", "comparableReservedDate", "requiresPermission", "canAssign", "canTransfer", "canUnreserve", "shareBatchId", "shareComparableExpireDate", "shareShareExpireDate", "shareReceiveUrl") SELECT "localId", "assignedToTemple", "bornInCovenant", "canPrint", "completedDate", "completedPlace", "fatherId", "fatherName", "motherId", "motherName", "reserve", "spouseId", "status", "type", "cacheHash", "lastFetchDate", "personReservationPid", "whyNotQualifying", "ownerName", "reservedDate", "comparableReservedDate", "requiresPermission", "canAssign", "canTransfer", "canUnreserve", "shareBatchId", "shareComparableExpireDate", "shareShareExpireDate", "shareReceiveUrl" FROM "main"."_Ordinance_old_20171023";
    CREATE UNIQUE INDEX "main"."INDEX_ordinance_server" ON Ordinance ("type" ASC, "personReservationPid" ASC, "fatherId" ASC, "motherId" ASC, "spouseId" ASC);
    DROP TABLE _Ordinance_old_20171023;


    /* PedigreePreferences */
    ALTER TABLE "main"."PedigreePreferences" RENAME TO "_PedigreePreferences_old_20171023";
    DROP INDEX "main"."INDEX_PedigreePreferences_pid";

    CREATE TABLE "main"."PedigreePreferences" (
      "localId" TEXT,
      "pid" TEXT NOT NULL,
      "preferredCoupleId" TEXT,
      "preferredParentChildId" TEXT,
      "preferredCoparentParentChildId" TEXT,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      PRIMARY KEY("localId")
    );

    INSERT INTO "main"."PedigreePreferences" ("localId", "pid", "preferredCoupleId", "preferredParentChildId", "preferredCoparentParentChildId", "cacheHash", "lastFetchDate") SELECT "localId", "pid", "preferredCoupleId", "preferredParentChildId", "preferredCoparentParentChildId", "cacheHash", "lastFetchDate" FROM "main"."_PedigreePreferences_old_20171023";
    CREATE UNIQUE INDEX "main"."INDEX_PedigreePreferences_pid" ON PedigreePreferences ("pid" ASC);
    DROP TABLE _PedigreePreferences_old_20171023;


    /* PersonReservation */
    ALTER TABLE "main"."PersonReservation" RENAME TO "_PersonReservation_old_20171023";
    DROP INDEX "main"."INDEX_personReservation_server";

    CREATE TABLE "main"."PersonReservation" (
      "localId" TEXT,
      "displayName" TEXT,
      "gender" TEXT,
      "givenName" TEXT,
      "lifespan" TEXT,
      "pid" TEXT,
      "surName" TEXT,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "hasDuplicate" INTEGER NOT NULL DEFAULT 0,
      PRIMARY KEY("localId")
    );

    INSERT INTO "main"."PersonReservation" ("localId", "displayName", "gender", "givenName", "lifespan", "pid", "surName", "cacheHash", "lastFetchDate", "hasDuplicate") SELECT "localId", "displayName", "gender", "givenName", "lifespan", "pid", "surName", "cacheHash", "lastFetchDate", "hasDuplicate" FROM "main"."_PersonReservation_old_20171023";
    CREATE UNIQUE INDEX "main"."INDEX_personReservation_server" ON PersonReservation ("pid" ASC);
    DROP TABLE _PersonReservation_old_20171023;


    /* PersonTasks */
    ALTER TABLE "main"."PersonTasks" RENAME TO "_PersonTasks_old_20171023";
    DROP INDEX "main"."INDEX_personTasks_listKey_pid";

    CREATE TABLE "main"."PersonTasks" (
      "localId" TEXT,
      "listKeyRaw" TEXT NOT NULL,
      "pid" TEXT NOT NULL,
      "sortKey" INTEGER NOT NULL,
      "hasHints" INTEGER NOT NULL,
      "templeStatus" INTEGER NOT NULL,
      "displayName" TEXT NOT NULL,
      "gender" INTEGER NOT NULL,
      "lifespan" TEXT,
      "living" INTEGER NOT NULL,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      PRIMARY KEY("localId")
    );

    INSERT INTO "main"."PersonTasks" ("localId", "listKeyRaw", "pid", "sortKey", "hasHints", "templeStatus", "displayName", "gender", "lifespan", "living", "cacheHash", "lastFetchDate") SELECT "localId", "listKeyRaw", "pid", "sortKey", "hasHints", "templeStatusRaw", "displayName", "genderRaw", "lifespan", "living", "cacheHash", "lastFetchDate" FROM "main"."_PersonTasks_old_20171023";
    CREATE UNIQUE INDEX "main"."INDEX_personTasks_listKey_pid" ON PersonTasks ("listKeyRaw" ASC, "pid" ASC);
    DROP TABLE _PersonTasks_old_20171023;


    /* PersonTasksLists */
    ALTER TABLE "main"."PersonTasksList" RENAME TO "_PersonTasksList_old_20171023";
    DROP INDEX "main"."INDEX_personTasksList_listKey";

    CREATE TABLE "main"."PersonTasksList" (
      "localId" TEXT,
      "listKeyRaw" TEXT NOT NULL,
      "numGens" INTEGER,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      PRIMARY KEY("localId")
    );

    INSERT INTO "main"."PersonTasksList" ("localId", "listKeyRaw", "numGens", "cacheHash", "lastFetchDate") SELECT "localId", "listKeyRaw", "numGens", "cacheHash", "lastFetchDate" FROM "main"."_PersonTasksList_old_20171023";
    CREATE UNIQUE INDEX "main"."INDEX_personTasksList_listKey" ON PersonTasksList ("listKeyRaw" ASC);
    DROP TABLE _PersonTasksList_old_20171023;
    """,

    """
    CREATE TABLE "main"."GeoEvent" (
      "localId" TEXT,
      "eventId" TEXT NOT NULL,
      "name" TEXT NOT NULL,
      "startTimestamp" REAL NOT NULL,
      "endTimestamp" REAL NOT NULL,
      "geofenceCenterLatitude" REAL NOT NULL,
      "geofenceCenterLongitude" REAL NOT NULL,
      "geofenceRadius" REAL NOT NULL,
      "optedIn" INTEGER NOT NULL,
      "colorHex" TEXT NOT NULL,
      "imageUrl" TEXT NOT NULL,
      "introText" TEXT NOT NULL,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      PRIMARY KEY("localId")
    );

    CREATE UNIQUE INDEX "main"."INDEX_geoEvent_eventId" ON GeoEvent ("eventId");

    CREATE TABLE "main"."GeoEventList" (
      "localId" TEXT,
      "listId" TEXT,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      PRIMARY KEY("localId")
    );

    CREATE UNIQUE INDEX "main"."INDEX_geoEventList_listId" ON GeoEventList ("listId");
    """,

    """
    CREATE TABLE "main"."SyncTask" (
      "localId" TEXT NOT NULL,
      "type" TEXT NOT NULL,
      "primaryLocalId" TEXT NOT NULL,
      "createdOn" INTEGER NOT NULL,
      "state" TEXT NOT NULL,
      "attemptCount" INTEGER NOT NULL,
      "lastAttemptDate" INTEGER NOT NULL,
      "message" TEXT,
      PRIMARY KEY("localId")
    );

    CREATE TABLE "main"."CacheTracker" (
      "localId" TEXT PRIMARY KEY,
      "typeRaw" TEXT,
      "entityId" TEXT,

      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL
    );
    CREATE UNIQUE INDEX "main"."INDEX_CacheTracker_typeRaw_entityId" ON CacheTracker ("typeRaw" ASC, "entityId" ASC);


    /* Drop artifactServerId column from the FSSource table */
    ALTER TABLE "main"."FSSource" RENAME TO "_FSSource_old_20171222";
    DROP INDEX "main"."INDEX_source_server";

    CREATE TABLE "main"."Source" (
      "localId" TEXT,
      "artifactLocalId" TEXT,
      "serverId" TEXT,
      "title" TEXT,
      "url" TEXT,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "syncInFlightStatus" INTEGER NOT NULL,
      "syncStatus" INTEGER NOT NULL,
      "notes" TEXT DEFAULT '',
      "citation" TEXT DEFAULT '',
      "contributorCisId" TEXT DEFAULT '',
      "modifiedTimestamp" INTEGER NOT NULL DEFAULT 0,
      "resourceType" TEXT '',
      "changeMessage" TEXT '',
      PRIMARY KEY("localId")
    );

    INSERT INTO "main"."Source" ("localId", "artifactLocalId", "serverId", "title", "url", "cacheHash", "lastFetchDate", "syncInFlightStatus", "syncStatus", "notes", "citation", "contributorCisId", "modifiedTimestamp", "resourceType", "changeMessage") SELECT "localId", "artifactLocalId", "serverId", "title", "url", "cacheHash", "lastFetchDate", "syncInFlightStatus", "syncStatus", "notes", "citation", "contributorCisId", "modifiedTimestamp", "resourceType", "changeMessage" FROM "main"."_FSSource_old_20171222";
    CREATE UNIQUE INDEX "main"."INDEX_source_server" ON Source ("serverId" ASC);
    DROP TABLE _FSSource_old_20171222;


    /* Drop artifactServerId, taggedPersonServerId, personaServerId and rename table */
    DROP INDEX "main"."INDEX_photoTag_server";
    DROP TABLE FSPhotoTag;

    CREATE TABLE "main"."Tag" (
      "localId" TEXT,
      "serverId" TEXT,
      "deletable" INTEGER NOT NULL DEFAULT 0,
      "editable" INTEGER NOT NULL DEFAULT 0,
      "height" REAL NOT NULL DEFAULT 0,
      "softTag" INTEGER NOT NULL DEFAULT 0,
      "artifactLocalId" TEXT,
      "taggedPersonLocalId" TEXT,
      "personaLocalId" STRING DEFAULT NULL,
      "taggedPersonPid" STRING DEFAULT '',
      "title" TEXT,
      "width" REAL NOT NULL DEFAULT 0,
      "x" REAL NOT NULL DEFAULT 0,
      "y" REAL NOT NULL DEFAULT 0,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "syncInFlightStatus" INTEGER NOT NULL,
      "syncStatus" INTEGER NOT NULL,
      PRIMARY KEY("localId")
    );

    CREATE UNIQUE INDEX "main"."INDEX_Tag_server" ON Tag ("serverId" ASC);


    /* Drop tables used to track things that CacheTracker can now be used for */
    DROP TABLE FSSourceReferenceList;
    DROP TABLE FSRelationships;
    DROP TABLE FSPersonNoteList;
    DROP TABLE FSHistoryList;
    DROP TABLE FSHintList;
    DROP TABLE GeoEventList;
    """,

    """
    ALTER TABLE FSPersonVitals ADD readOnly INTEGER NOT NULL DEFAULT 0;

    ALTER TABLE FSRecordHint ADD primaryEventType TEXT;

    ALTER TABLE Ordinance ADD owner STRING DEFAULT '';

    /* Album */
    ALTER TABLE "main"."Album" RENAME TO "_Album_old_20181023";
    DROP INDEX "main"."INDEX_album_server";

    CREATE TABLE "main"."Album" (
    "localId" TEXT,
    "serverId" TEXT,
    "listType" INTEGER NOT NULL,
    "albumName" TEXT,
    "albumDescription" TEXT,
    "contributorPatronId" INTEGER NOT NULL,
    "uploaderId" INTEGER NOT NULL,
    "restrictionState" TEXT NOT NULL,
    "artifactCount" INTEGER NOT NULL,
    "thumbUrl" TEXT,
    "thumbSquareUrl" TEXT,
    "thumbIconUrl" TEXT,
    "seoIndexable" INTEGER NOT NULL,
    "favorite" INTEGER NOT NULL,
    "editableByCaller" INTEGER NOT NULL,
    "cacheHash" TEXT,
    "lastFetchDate" REAL NOT NULL,
    PRIMARY KEY("localId")
    );

    INSERT INTO "main"."Album" ("localId", "serverId", "listType", "albumName", "albumDescription", "contributorPatronId", "uploaderId", "restrictionState", "artifactCount", "thumbUrl", "thumbSquareUrl", "thumbIconUrl", "seoIndexable", "favorite", "editableByCaller", "cacheHash", "lastFetchDate") SELECT "localId", "serverId", "listType", "albumName", "albumDescription", "contributorPatronId", "uploaderId", "restrictionState", "artifactCount", "thumbUrl", "thumbSquareUrl", "thumbIconUrl", "seoIndexable", "favorite", "editableByCaller", "cacheHash", "lastFetchDate" FROM "main"."_Album_old_20181023";
    CREATE UNIQUE INDEX "main"."INDEX_album_server" ON Album ("serverId" ASC);
    DROP TABLE _Album_old_20181023;
    """,

    """
    ALTER TABLE FSArtifact ADD iconLocalId TEXT;

    """,

    """
    ALTER TABLE FSSourceReference ADD nameTagged INTEGER NOT NULL DEFAULT 0;
    ALTER TABLE FSSourceReference ADD genderTagged INTEGER NOT NULL DEFAULT 0;
    ALTER TABLE FSSourceReference ADD birthTagged INTEGER NOT NULL DEFAULT 0;
    ALTER TABLE FSSourceReference ADD christeningTagged INTEGER NOT NULL DEFAULT 0;
    ALTER TABLE FSSourceReference ADD deathTagged INTEGER NOT NULL DEFAULT 0;
    ALTER TABLE FSSourceReference ADD burialTagged INTEGER NOT NULL DEFAULT 0;

    ALTER TABLE FSPersonVitals ADD confidential INTEGER NOT NULL DEFAULT 0;
    """,

    """
    CREATE TABLE "main"."XTGroup" (
      "localId" TEXT,
      "groupId" TEXT,
      "title" TEXT,
      "description" TEXT,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      PRIMARY KEY("localId")
    );
    CREATE UNIQUE INDEX "main"."INDEX_xtgroup_groupId" ON XTGroup ("groupId" ASC);

    CREATE TABLE "main"."XTGroupMember" (
      "localId" TEXT,
      "id" TEXT,
      "groupId" TEXT,
      "displayName" TEXT,
      "cisId" TEXT,
      "thumbUrl" TEXT,
      "gender" TEXT,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      PRIMARY KEY("localId")
    );
    CREATE UNIQUE INDEX "main"."INDEX_xtgroupmember_groupId_cisid" ON XTGroupMember ("cisId", "groupId" ASC);

    ALTER TABLE Ordinance ADD xtSharedWithGroupId TEXT DEFAULT NULL;
    ALTER TABLE Ordinance ADD xtReservationId INTEGER DEFAULT -1;
    ALTER TABLE Ordinance ADD xtSharedByMe INTEGER DEFAULT 0;
    ALTER TABLE Ordinance ADD xtOriginalOwnerId TEXT DEFAULT NULL;

    CREATE TABLE "main"."XTMessage" (
      "localId" TEXT,
      "groupId" TEXT,
      "messageId" INTEGER NOT NULL DEFAULT 0,
      "parentMessageId" INTEGER DEFAULT 0,
      "cisId" TEXT,
      "dataString" TEXT,
      "type" TEXT,
      "createDate" INTEGER NOT NULL DEFAULT 0,
      "updateDate" INTEGER NOT NULL DEFAULT 0,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      PRIMARY KEY("localId")
    );
    CREATE UNIQUE INDEX "main"."INDEX_xtmessage_messageId" ON XTMessage ("messageId" ASC);
    """,

    """
    ALTER TABLE Ordinance ADD expiryDate TEXT DEFAULT '';
    ALTER TABLE Ordinance ADD comparableExpiryDate TEXT DEFAULT '';
    """,

    """
    ALTER TABLE FSFact ADD dateMonth INTEGER NOT NULL DEFAULT 0;
    ALTER TABLE FSFact ADD dateDay INTEGER NOT NULL DEFAULT 0;

    CREATE TABLE "Portrait" (
      "localId" TEXT,
      "serverId" TEXT,
      "pid" TEXT,
      "x" REAL,
      "y" REAL,
      "width" REAL,
      "height" REAL,
      "rotation" REAL,
      "processingState" TEXT,
      "screeningState" TEXT,
      "artifactLocalId" TEXT,
      "artifactServerId" TEXT,
      "reason" TEXT,
      "originalUrl" TEXT,
      "thumbIconUrl" TEXT,
      "thumbSquareUrl" TEXT,
      "mediaType" TEXT,
      "cacheHash" TEXT,
      "syncInFlightStatus" INTEGER NOT NULL,
      "syncStatus" INTEGER NOT NULL,
      PRIMARY KEY("localId")
    );

    CREATE UNIQUE INDEX "main"."INDEX_portrait_pid" ON Portrait ("pid");

    DROP TABLE FSPersonPotentialPortrait;
    """,

    """
    ALTER TABLE XTGroupMember ADD role TEXT NOT NULL DEFAULT "MEMBER";
    ALTER TABLE XTGroupMember ADD statsString TEXT;
    ALTER TABLE XTGroup ADD statsString TEXT;

    CREATE TABLE "main"."XTMessageActivity" (
      "localId" TEXT,
      "activityId" INTEGER,
      "cisId" TEXT,
      "action" TEXT,
      "entityType" TEXT,
      "entityId" TEXT,
      "quantity" INTEGER,
      "activityTimestamp" REAL,
      PRIMARY KEY("localId")
    );
    CREATE UNIQUE INDEX "main"."INDEX_xtmessageactivity_activityId" ON XTMessageActivity ("activityId" ASC);
    """,

    """
    ALTER TABLE XTGroup ADD experimentEnd REAL;
    """,

    """
    ALTER TABLE FSArtifact ADD parentArtifactLocalId TEXT DEFAULT NULL;
    """,

    """
    ALTER TABLE FSFOR ADD forNumber TEXT DEFAULT NULL;
    """,

    """
    ALTER TABLE Artifact_Associations ADD sortOrder INTEGER NOT NULL DEFAULT 0;
    """,

    """
    ALTER TABLE FSUser ADD cardsNotReturned INTEGER NOT NULL DEFAULT 0;
    """,

    """
    UPDATE FSFact SET ownerEntityId = REPLACE(ownerEntityId, 'mother', 'parent2');
    UPDATE FSFact SET ownerEntityId = REPLACE(ownerEntityId, 'father', 'parent1');

    ALTER TABLE "main"."FSParentChild" RENAME TO "_FSParentChild_old_20190402";
    DROP INDEX "main"."INDEX_parentChild_server";

    CREATE TABLE "main"."ParentChild" (
      "localId" TEXT,
      "relationshipId" TEXT,
      "childId" TEXT,
      "parent1Id" TEXT,
      "parent2Id" TEXT,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "parentSortKey" INTEGER NOT NULL DEFAULT 0,
      "childSortKey" INTEGER NOT NULL DEFAULT 0,
      PRIMARY KEY("localId")
    );

    INSERT INTO "main"."ParentChild" ("localId", "relationshipId", "childId", "parent1Id", "parent2Id", "cacheHash", "lastFetchDate", "parentSortKey", "childSortKey") SELECT "localId", "relationshipId", "childId", "fatherId", "motherId", "cacheHash", "lastFetchDate", "parentSortKey", "childSortKey" FROM "main"."_FSParentChild_old_20190402";
    CREATE UNIQUE INDEX "main"."INDEX_parentChild_server" ON ParentChild ("relationshipId" ASC);
    DROP TABLE _FSParentChild_old_20190402;



    ALTER TABLE "main"."Ordinance" RENAME TO "_Ordinance_old_20190402";
    DROP INDEX "main"."INDEX_ordinance_server";

    CREATE TABLE "main"."Ordinance" (
      "localId" TEXT,
      "assignedToTemple" INTEGER NOT NULL,
      "bornInCovenant" INTEGER NOT NULL,
      "canPrint" INTEGER NOT NULL,
      "completedDate" TEXT,
      "completedPlace" TEXT,
      "parent1Id" TEXT,
      "parent1Name" TEXT,
      "parent1Gender" INTEGER,
      "parent2Id" TEXT,
      "parent2Name" TEXT,
      "parent2Gender" INTEGER,
      "reserve" INTEGER NOT NULL,
      "spouseId" TEXT,
      "status" INTEGER NOT NULL,
      "type" INTEGER NOT NULL,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "personReservationPid" TEXT,
      "whyNotQualifying" TEXT DEFAULT NULL,
      "ownerName" TEXT DEFAULT '',
      "reservedDate" TEXT DEFAULT '',
      "comparableReservedDate" TEXT DEFAULT '',
      "requiresPermission" INTEGER NOT NULL,
      "canAssign" INTEGER NOT NULL DEFAULT 0,
      "canTransfer" INTEGER NOT NULL DEFAULT 0,
      "canUnreserve" INTEGER NOT NULL DEFAULT 0,
      "shareBatchId" STRING DEFAULT '',
      "shareComparableExpireDate" STRING DEFAULT '',
      "shareShareExpireDate" STRING DEFAULT '',
      "shareReceiveUrl" STRING DEFAULT '',
      "owner" STRING DEFAULT '',
      "xtSharedWithGroupId" TEXT DEFAULT NULL,
      "xtReservationId" INTEGER DEFAULT -1,
      "xtSharedByMe" INTEGER DEFAULT 0,
      "xtOriginalOwnerId" TEXT DEFAULT NULL,
      "expiryDate" TEXT DEFAULT '',
      "comparableExpiryDate" TEXT DEFAULT '',
      PRIMARY KEY("localId")
    );

    INSERT INTO "main"."Ordinance" ("localId", "assignedToTemple", "bornInCovenant", "canPrint", "completedDate", "completedPlace", "parent1Id", "parent1Name", "parent1Gender", "parent2Id", "parent2Name", "parent2Gender", "reserve", "spouseId", "status", "type", "cacheHash", "lastFetchDate", "personReservationPid", "whyNotQualifying", "ownerName", "reservedDate", "comparableReservedDate", "requiresPermission", "canAssign", "canTransfer", "canUnreserve", "shareBatchId", "shareComparableExpireDate", "shareShareExpireDate", "shareReceiveUrl", "owner", "xtSharedWithGroupId", "xtReservationId", "xtSharedByMe", "xtOriginalOwnerId", "expiryDate", "comparableExpiryDate") SELECT "localId", "assignedToTemple", "bornInCovenant", "canPrint", "completedDate", "completedPlace", "fatherId", "fatherName", 1, "motherId", "motherName", 2, "reserve", "spouseId", "status", "type", "cacheHash", "lastFetchDate", "personReservationPid", "whyNotQualifying", "ownerName", "reservedDate", "comparableReservedDate", "requiresPermission", "canAssign", "canTransfer", "canUnreserve", "shareBatchId", "shareComparableExpireDate", "shareShareExpireDate", "shareReceiveUrl", "owner", "xtSharedWithGroupId", "xtReservationId", "xtSharedByMe", "xtOriginalOwnerId", "expiryDate", "comparableExpiryDate" FROM "main"."_Ordinance_old_20190402";
    CREATE UNIQUE INDEX "main"."INDEX_ordinance_server" ON Ordinance ("type" ASC, "personReservationPid" ASC, "parent1Id" ASC, "parent2Id" ASC, "spouseId" ASC);
    DROP TABLE _Ordinance_old_20190402;

    CREATE TABLE "main"."OtherApp" (
      "name" TEXT NOT NULL,
      "appStoreUrl" TEXT NOT NULL,
      "imageUrl" TEXT NOT NULL,
      "urlScheme" TEXT
    );
    CREATE UNIQUE INDEX "main"."INDEX_OtherApp_appStoreUrl" ON OtherApp ("appStoreUrl" ASC);


    /* Contributor Table Updates */
    DROP INDEX "main"."INDEX_contributor_server";
    DROP TABLE FSContributor;

    CREATE TABLE "main"."FSContributor" (
      "localId" TEXT NOT NULL,
      "key" TEXT,
      "contributorId" TEXT,
      "artifactPatronId" TEXT,
      "contactName" TEXT,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "email" STRING DEFAULT '',
      "phoneNumber" STRING DEFAULT '',
      "cisUserId" STRING DEFAULT '',
      "relationshipPathData" blob,
      "relationshipDescription" TEXT,
      "optedInToUserRelationship" integer NOT NULL DEFAULT 0,
      "surname" TEXT DEFAULT NULL,
      "givenName" TEXT DEFAULT NULL,
      PRIMARY KEY("localId")
    );

    CREATE UNIQUE INDEX "main"."INDEX_contributor_server" ON FSContributor ("contributorId" ASC);
    """,

    """
    CREATE TABLE "DCamItem" (
      "localId" TEXT,
      "workstationId" TEXT,
      "direction" TEXT,
      "fileName" TEXT,
      "uploadUrl" TEXT,
      "capturedOn" REAL,
      "transferedOn" REAL,
      "cacheHash" TEXT,
      "syncInFlightStatus" INTEGER NOT NULL,
      "syncStatus" INTEGER NOT NULL,
      PRIMARY KEY("localId")
    );

    CREATE TABLE "DCamWorkstation" (
      "localId" TEXT,
      "workstationId" TEXT,
      "projectIds" BLOB,
      "nickName" TEXT,
      "ipAddress" TEXT,
      PRIMARY KEY("localId")
    );

    CREATE UNIQUE INDEX "main"."INDEX_dcamworkstation_workstationId" ON DCamWorkstation ("workstationId");
    """,

    """
    ALTER TABLE FSUser ADD gender INTEGER;
    """,

    """
    CREATE TABLE "ArtifactDatePlace" (
      "localId" TEXT,
      "serverId" TEXT DEFAULT NULL,
      "artifactLocalId" TEXT,
      "dateNonStandardizedText" TEXT DEFAULT NULL,
      "dateNormalizedText" TEXT DEFAULT NULL,
      "placeRepId" TEXT DEFAULT NULL,
      "placeNormalizedText" TEXT DEFAULT NULL,
      "placeNonStandardizedText" TEXT DEFAULT NULL,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "syncInFlightStatus" INTEGER NOT NULL,
      "syncStatus" INTEGER NOT NULL,
      PRIMARY KEY("localId")
    );
    CREATE UNIQUE INDEX "main"."INDEX_artifactDatePlace_server" ON ArtifactDatePlace ("serverId");
    """,

    """
    ALTER TABLE FSContributor ADD invitePending INTEGER NOT NULL DEFAULT 0;

    ALTER TABLE Source ADD displayDate TEXT;
    ALTER TABLE Source ADD sortYear TEXT;
    ALTER TABLE Source ADD sortKey TEXT;
    """,

    """
    CREATE TABLE "ArtifactComment" (
      "localId" TEXT,
      "commentId" TEXT,
      "artifactLocalId" TEXT,
      "text" TEXT,
      "cisId" TEXT,
      "createdDate" REAL,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "syncInFlightStatus" INTEGER NOT NULL,
      "syncStatus" INTEGER NOT NULL,
      PRIMARY KEY("localId")
    );
    CREATE UNIQUE INDEX "main"."INDEX_artifactComment_commentId" ON ArtifactComment ("commentId");
    """,

    """
    ALTER TABLE FSConversation ADD folderFilter TEXT;

    CREATE TABLE "ConversationFolder" (
      "localId" TEXT,
      "folderFilter" TEXT,
      "displayName" TEXT,
      "newMessageCount" INTEGER,
      "sortOrder" INTEGER,
      PRIMARY KEY("localId")
    );
    """,

    """
    ALTER TABLE "main"."FSPersonVitals" RENAME TO "_FSPersonVitals_old_20191218";

    DROP INDEX "main"."INDEX_person_server";

    CREATE TABLE "main"."Person" (
       "localId" TEXT,
       "pid" TEXT NOT NULL,
       "displayName" TEXT,
       "givenName" TEXT,
       "surName" TEXT,
       "suffix" TEXT,
       "nameOrder" TEXT DEFAULT "eurotypic",
       "nameSeparator" TEXT DEFAULT " ",
       "gender" INTEGER,
       "lifespan" TEXT,
       "living" INTEGER NOT NULL DEFAULT 0,
       "readOnly" INTEGER NOT NULL DEFAULT 0,
       "confidential" INTEGER NOT NULL DEFAULT 0,
       "photoCount" INTEGER,
       "sourceCount" INTEGER,
       "storyCount" INTEGER,
       "researchSuggestionCount" INTEGER,
       "dataProblemCount" INTEGER,
       "birthCountry" TEXT,
       "hasRecordHints" INTEGER,
       "hasPossibleDuplicates" INTEGER,
       "templeStatus" TEXT,
       "cacheHash" TEXT,
       "lastFetchDate" REAL NOT NULL,
      PRIMARY KEY("localId")
    );

    INSERT INTO "main"."Person" ("localId", "pid", "displayName", "givenName", "surName", "suffix", "gender", "lifespan", "living", "readOnly", "confidential", "cacheHash", "lastFetchDate") SELECT "localId", "pid", "displayName", "givenName", "surName", "suffix", "gender", "lifespan", "living", "readOnly", "confidential", "cacheHash", "lastFetchDate" FROM "main"."_FSPersonVitals_old_20191218";
    CREATE UNIQUE INDEX "main"."INDEX_person_server" ON Person ("pid" ASC);
    DROP TABLE _FSPersonVitals_old_20191218;


    CREATE TABLE "main"."FanChart" (
       "localId" TEXT,
       "pid" TEXT NOT NULL,
       "generations" INTEGER,
       "dataOptions" INTEGER,
       "cacheHash" TEXT,
       "lastFetchDate" REAL NOT NULL,
      PRIMARY KEY("localId")
    );
    CREATE UNIQUE INDEX "main"."INDEX_FanChart_server" ON FanChart ("pid", "generations", "dataOptions");

    CREATE TABLE "main"."FanChartPosition" (
       "rootPid" TEXT NOT NULL,
       "position" TEXT NOT NULL,
       "generations" INTEGER NOT NULL,
       "pid" TEXT
    );

    ALTER TABLE FSContributor ADD hasContacted INTEGER;
    ALTER TABLE FSContributor ADD isConsultant INTEGER;
    ALTER TABLE FSContributor ADD displayName TEXT;
    """,

    """
    CREATE TABLE "ArtifactTopicTag" (
      "localId" TEXT,
      "topicId" TEXT,
      "artifactLocalId" TEXT,
      "text" TEXT,
      "useCount" INTEGER,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      "syncInFlightStatus" INTEGER NOT NULL,
      "syncStatus" INTEGER NOT NULL,
      PRIMARY KEY("localId")
    );
    CREATE UNIQUE INDEX "main"."INDEX_artifactTopicTag_topicId" ON ArtifactTopicTag ("topicId", "artifactLocalId");
    """,

    """
    ALTER TABLE Source ADD unfinishedAttachments INTEGER NOT NULL DEFAULT 0;
    ALTER TABLE List_Artifact ADD sortKey INTEGER NOT NULL DEFAULT 0;

    /* Data Fixup to retry tags that failed because of a 409 error */
    UPDATE Tag
    SET syncStatus = 1,
        syncInFlightStatus = 3
    WHERE localId IN (
      SELECT primaryLocalId FROM SyncTask
      WHERE type = 'tagAdd' AND
            state = 'failed' AND
            message LIKE '%org.familysearch.tag.create.failed Code=409%'
    );

    UPDATE SyncTask
    SET state = 'ready', message = NULL
    WHERE type = 'tagAdd' AND
          state = 'failed' AND
          message LIKE '%org.familysearch.tag.create.failed Code=409%';
    """,

    """
    DROP TABLE Ordinance;
    DROP TABLE FSReservations;
    DROP TABLE PersonReservation;
    DROP TABLE XTGroup;
    DROP TABLE XTGroupMember;
    DROP TABLE XTMessage;
    DROP TABLE XTMessageActivity;

    UPDATE Person SET templeStatus = REPLACE(templeStatus, 'unknown', 'COMPLETED');
    UPDATE Person SET templeStatus = REPLACE(templeStatus, 'completed', 'COMPLETED');
    UPDATE Person SET templeStatus = REPLACE(templeStatus, 'reserved', 'RESERVED');
    UPDATE Person SET templeStatus = REPLACE(templeStatus, 'ready', 'READY');
    UPDATE Person SET templeStatus = REPLACE(templeStatus, 'needsMoreInformation', 'NEED_MORE_INFORMATION');
    UPDATE Person SET templeStatus = REPLACE(templeStatus, 'needsPermission', 'NEED_PERMISSION');
    UPDATE Person SET templeStatus = REPLACE(templeStatus, 'notReady', 'NOT_READY');

    CREATE TABLE "main"."Ordinance" (
       "localId" text NOT NULL,
       "ownerEntityId" text NOT NULL,
       "personId" text,
       "spouseId" text,
       "parent1Id" text,
       "parent2Id" text,
       "type" text,
       "status" text,
       "printable" integer,
       "reservable" integer,
       "unReservable" integer,
       "shareable" integer,
       "unShareable" integer,
       "transferable" integer,
       "ownerId" text,
       "ownerContactName" text,
       "reserveTime" real,
       "expireTime" real,
       "sharedWithTempleTime" real,
       "templeDisplayDate" text,
       "templeDisplayPlace" text,
       "uniqueIdentifier" text NOT NULL,
       "displayStatusData" blob,
      PRIMARY KEY("localId")
    );
    CREATE UNIQUE INDEX "main"."INDEX_ordinance_unique" ON Ordinance ("uniqueIdentifier");

    CREATE TABLE "main"."Card" (
       "localId" text NOT NULL,
       "type" text,
       "status" text,
       "assignmentType" text,
       "sortOrder" text,
       "personId" text,
       "spouseId" text,
       "parent1Id" text,
       "parent2Id" text,
       "sortKey" real,
       "reservable" integer,
       "printable" integer,
       "unReservable" integer,
       "shareable" integer,
       "unShareable" integer,
       "transferable" integer,
       "reserveTime" real,
       "expireTime" real,
       "visibleContentHash" text,
       "transferUrl" text,
       "transferExpireTime" real,
       "sharedWithTempleTime" real,
       "messagesData" blob,
      PRIMARY KEY("localId")
    );
    CREATE UNIQUE INDEX "main"."INDEX_cards_ids" ON "Card" ("type", "assignmentType", "sortOrder", "personId", "spouseId");

    CREATE TABLE "ReservationList" (
      "localId" TEXT PRIMARY KEY,
      "contributorId" TEXT NOT NULL,
      "assignmentType" TEXT NOT NULL,
      "sortOrder" TEXT NOT NULL,
      "personalCardCount" INTEGER,
      "templeSharedCardCount" INTEGER,
      "completedCount" INTEGER,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL
    );
    CREATE UNIQUE INDEX "main"."INDEX_reservationList" ON "ReservationList" ("contributorId", "assignmentType", "sortOrder");

    DROP TABLE FSPedigree;

    CREATE TABLE "main"."Tree" (
      "localId" TEXT,
      "_root1Pid" TEXT NOT NULL,
      "_root2Pid" TEXT NOT NULL,
      "ownerEntityId" TEXT NOT NULL,
      "dataOptions" INTEGER,
      "cacheHash" TEXT,
      "lastFetchDate" REAL NOT NULL,
      PRIMARY KEY("localId")
    );
    CREATE UNIQUE INDEX "main"."INDEX_Tree_server" ON Tree ("_root1Pid", "_root2Pid", "dataOptions");

    CREATE TABLE "main"."TreePosition" (
      "ownerEntityId" TEXT NOT NULL,
      "rootPid" TEXT NOT NULL,
      "position" TEXT NOT NULL,
      "pid" TEXT
    );

    ALTER TABLE Place ADD localizedType TEXT;
    """,

    """
    ALTER TABLE Ordinance ADD secondaryOwnerId TEXT;
    ALTER TABLE Ordinance ADD secondaryOwnerContactName TEXT;
    ALTER TABLE Ordinance ADD secondaryReserveTime REAL;
    ALTER TABLE Ordinance ADD secondaryExpireTime REAL;

    ALTER TABLE Card ADD ownerId TEXT;
    ALTER TABLE Card ADD ownerContactName TEXT;
    ALTER TABLE Card ADD secondaryOwnerId TEXT;
    ALTER TABLE Card ADD secondaryOwnerContactName TEXT;
    ALTER TABLE Card ADD secondaryReserveTime REAL;
    ALTER TABLE Card ADD secondaryExpireTime REAL;

    ALTER TABLE FSMyArtifacts ADD archiveState TEXT NOT NULL DEFAULT notArchived;
    """
  ]
}
