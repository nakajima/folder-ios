//
//  Folder.swift
//
//
//  Created by Pat Nakajima on 10/6/23.
//

import GRDB
import Foundation
import pat_swift

public struct Folder: Model, Equatable {
	public var id: Int
	public var nodeID: String
	public var name: String
	public var orderedTrackIDs: String

	public static func assign(track: Track, to folder: Folder, in queue: DatabaseQueue) async {
		await Log.catch("Error assigning track to folder") {
			try await queue.write { db in
				try FolderTrack(trackID: track.id, folderID: folder.id).insert(db)
			}
		}
	}

	public static func clear(track: Track, in queue: DatabaseQueue) async {
		await Log.catch("Error clearing folders") {
			try await queue.write { db in
				try FolderTrack.filter(Column("trackID") == track.id).deleteAll(db)
			}
		}
	}

	public static func list(track: Track, in queue: DatabaseQueue) async -> [Folder] {
		do {
			return try await queue.read { db in
				let folderTracks = try FolderTrack.filter(Column("trackID") == track.id).fetchAll(db)
				return try Folder.filter(folderTracks.map(\.folderID).contains(Column("id"))).fetchAll(db)
			}
		} catch {
			return []
		}
	}

	public static func list(folder: Folder, in queue: DatabaseQueue) async -> [Track] {
		do {
			return try await queue.read { db in
				let folderTracks = try FolderTrack.filter(Column("folderID") == folder.id).fetchAll(db)
				return try Track.filter(folderTracks.map(\.trackID).contains(Column("id"))).fetchAll(db)
			}
		} catch {
			return []
		}
	}
}

struct FolderTrack: Model {
	var id: Int?
	var trackID: Int
	var folderID: Int
}
