//
//  TracksProvider.swift
//
//
//  Created by Pat Nakajima on 10/5/23.
//

import GRDB
import GRDBQuery
import SwiftUI
import Combine

public struct TrackWithCurrentVersion: Identifiable {
	public var id: Int {
		track.id
	}

	public var track: Track
	public var currentVersion: TrackVersion

	public init(track: Track, currentVersion: TrackVersion) {
		self.track = track
		self.currentVersion = currentVersion
	}
}

struct TracksRequest: Queryable {
	static var defaultValue: [TrackWithCurrentVersion] = []

	func publisher(in dbQueue: DatabaseQueue) -> AnyPublisher<[TrackWithCurrentVersion], Error> {
		ValueObservation
			.tracking { db in
				let tracks = try Track.order(sql: "updatedAt DESC").fetchAll(db)

				return try tracks.compactMap { track in
					guard let version = try TrackVersion.fetchOne(db, key: track.currentVersionID) else {
						return nil
					}

					return TrackWithCurrentVersion(track: track, currentVersion: version)
				}
			}
		// The `.immediate` scheduling feeds the view right on subscription,
		// and avoids an initial rendering with an empty list:
		.publisher(in: dbQueue, scheduling: .immediate)
		.eraseToAnyPublisher()
	}
}

struct TrackLoaderWrapper<Content: View>: View {
	var queue: DatabaseQueue
	var apiClient: ApiClient
	var loader: TrackLoader
	var content: (TrackLoader) -> Content

	init(queue: DatabaseQueue, apiClient: ApiClient, content: @escaping (TrackLoader) -> Content) {
		self.queue = queue
		self.apiClient = apiClient
		self.content = content
		self.loader = TrackLoader(queue: queue, client: apiClient)
	}

	var body: some View {
		content(loader)
	}
}

public struct TracksProvider<Content: View>: View {
	@Environment(\.apiClient) var client
	@Environment(\.dbQueue) var queue

	var content: (TrackLoader, [TrackWithCurrentVersion]) -> Content

	@Query(TracksRequest(), in: \.dbQueue) var tracks: [TrackWithCurrentVersion]

	public init(content: @escaping (TrackLoader, [TrackWithCurrentVersion]) -> Content) {
		self.content = content
	}

	public var body: some View {
		TrackLoaderWrapper(queue: queue, apiClient: client) { loader in
			content(loader, tracks)
		}
	}
}

#Preview {
	DBProvider(.memory) {
		ClientProvider {
			TracksProvider { _, _ in
				Text("Hi")
			}
		}
	}
}
