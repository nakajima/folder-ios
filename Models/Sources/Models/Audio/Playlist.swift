//
//  Playlist.swift
//
//
//  Created by Pat Nakajima on 10/6/23.
//

import Foundation
import GRDB

public protocol Playlist {
	var dbQueue: DatabaseQueue { get }

	func next(current: NowPlaying?) async -> (Track, TrackVersion)?
	func previous(current: NowPlaying?) async -> (Track, TrackVersion)?
	func list() async -> [(Track, TrackVersion)]
}

public struct AllTracksPlaylist: Playlist {
	public var dbQueue: DatabaseQueue

	public init(dbQueue: DatabaseQueue) {
		self.dbQueue = dbQueue
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
			let tracks = try await self.dbQueue.read { db in
				try Track.order(literal: "updatedAt DESC").fetchAll(db)
			}

			return try await self.dbQueue.read { db in
				return try tracks.compactMap { track in
					guard let version = try TrackVersion.filter(Column("id") == track.currentVersionID).fetchOne(db) else {
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
