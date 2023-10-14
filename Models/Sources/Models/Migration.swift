//
//  Migration.swift
//
//
//  Created by Pat Nakajima on 10/13/23.
//

import Foundation
import GRDB
import pat_swift

struct Migration {
	static func run(in queue: DatabaseQueue) {
		Log.catch {
			try queue.write { db in
				try Track.createTable(in: db)
				try TrackVersion.createTable(in: db)
				try Folder.createTable(in: db)
				try Tag.createTable(in: db)
				try FolderTrack.createTable(in: db)
			}
		}
	}
}

extension Folder {
	static func createTable(in db: Database) throws {
		try db.create(table: "folder", ifNotExists: true) { t in
			t.primaryKey {
				t.column("id", .integer).notNull().unique()
			}

			t.column("nodeID", .text).notNull()
			t.column("name", .text).notNull()
			t.column("orderedTrackIDs", .text).notNull()
		}
	}
}

extension Track {
	static func createTable(in db: Database) throws {
		try db.create(table: "track", ifNotExists: true) { t in
			t.column("id", .integer).notNull().unique().primaryKey()
			t.column("nodeID", .text).notNull()
			t.column("name", .text).notNull()
			t.column("updatedAt", .datetime).notNull()
			t.column("shareURL", .text).notNull()
			t.column("currentVersionID", .integer)
			t.column("analyzedAt", .datetime).notNull().defaults(to: Date.distantPast)
		}
	}
}

extension TrackVersion {
	static func createTable(in db: Database) throws {
		try db.create(table: "trackVersion", ifNotExists: true) { t in
			t.column("id", .integer).notNull().unique().primaryKey()
			t.column("nodeID", .text).notNull()
			t.column("duration", .integer)
			t.column("number", .integer).notNull()
			t.column("trackID", .integer).notNull().indexed().references("track")
			t.column("uuid", .text).notNull()
			t.column("isCurrent", .boolean).notNull().defaults(to: false)
			t.column("status", .text).notNull().defaults(to: VersionDownloader.State.unknown.rawValue)
		}
	}
}

extension Tag {
	static func createTable(in db: Database) throws {
		try db.create(table: "tag", ifNotExists: true) { t in
			t.autoIncrementedPrimaryKey("id")
			t.column("name", .text).notNull()
			t.column("trackID", .integer).notNull().indexed().references("track")
			t.uniqueKey(["name", "trackID"], onConflict: .ignore)
		}
	}
}

extension FolderTrack {
	static func createTable(in db: Database) throws {
		try db.create(table: "folderTrack", ifNotExists: true) { t in
			t.autoIncrementedPrimaryKey("id")
			t.column("trackID", .integer).notNull().indexed().references("track")
			t.column("folderID", .integer).notNull().indexed().references("folder")
			t.uniqueKey(["trackID", "folderID"], onConflict: .ignore)
		}
	}
}
