//
//  Playlist.swift
//
//
//  Created by Pat Nakajima on 10/6/23.
//

import Foundation

public protocol Playlist {
	var database: Database { get }

	func next(current: NowPlaying?) async -> (Track, TrackVersion)?
	func previous(current: NowPlaying?) async -> (Track, TrackVersion)?
	func list() async -> [(Track, TrackVersion)]
}

public struct AllTracksPlaylist: Playlist {
	public var database: Database

	public init(database: Database) {
		self.database = database
	}

	public func next(current: NowPlaying?) async -> (Models.Track, Models.TrackVersion)? {
		let list = await list()

		guard let index = list.firstIndex(where: { $0 == current?.track && $1 == current?.version }) else {
			return list.first
		}

		return list.indices.contains(index + 1) ? list[index + 1] : list.first
	}

	public func previous(current: NowPlaying?) async -> (Models.Track, Models.TrackVersion)? {
		let list = await list()

		guard let index = list.firstIndex(where: { $0 == current?.track && $1 == current?.version }) else {
			return list.first
		}

		return list.indices.contains(index - 1) ? list[index - 1] : list.last
	}

	public func list() async -> [(Models.Track, Models.TrackVersion)] {
		do {
			let tracks = try await Track.read(from: database, orderBy: .descending(\.$updatedAt))

			return try await database.transaction { core in
				try tracks.compactMap { track in
					guard let version = try TrackVersion.readIsolated(from: database, core: core, id: track.currentVersionID) else {
						return nil
					}

					return (track, version)
				}
			}
		} catch {
			return []
		}
	}
}
