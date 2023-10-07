//
//  Folder.swift
//
//
//  Created by Pat Nakajima on 10/6/23.
//

import Foundation
import Blackbird
import pat_swift

public struct Folder: BlackbirdModel {
	@BlackbirdColumn public var id: Int
	@BlackbirdColumn public var nodeID: String
	@BlackbirdColumn public var name: String
	@BlackbirdColumn public var orderedTrackIDs: String

	public static func assign(track: Track, to folder: Folder, in database: Database) async {
		await Log.catch("Error assigning track to folder") {
			try await FolderTrack(trackID: track.id, folderID: folder.id).write(to: database)
		}
	}

	public static func clear(track: Track, in database: Database) async {
		await Log.catch("Error clearing folders") {
			try await FolderTrack.delete(from: database, matching: \.$trackID == track.id)
		}
	}

	public static func list(track: Track, in database: Database) async -> [Folder] {
		do {
			let folders = try await FolderTrack.read(from: database, matching: \.$trackID == track.id)
			return try await Folder.read(from: database, primaryKeys: folders.map(\.folderID))
		} catch {
			return []
		}
	}

	public static func list(folder: Folder, in database: Database) async -> [Track] {
		do {
			let joins = try await FolderTrack.read(from: database, matching: \.$folderID == folder.id)
			return try await Track.read(from: database, primaryKeys: joins.map(\.trackID))
		} catch {
			return []
		}
	}
}

fileprivate struct FolderTrack: BlackbirdModel {
	@BlackbirdColumn var id = UUID().uuidString
	@BlackbirdColumn var trackID: Int
	@BlackbirdColumn var folderID: Int
}
