//
//  TrackVersionsProvider.swift
//
//
//  Created by Pat Nakajima on 10/5/23.
//

import GRDB
import GRDBQuery
import Combine
import SwiftUI

struct TrackVersionsRequest: Queryable {
	static var defaultValue: [TrackVersion] = []
	var track: Track?

	func publisher(in dbQueue: DatabaseQueue) -> AnyPublisher<[TrackVersion], Error> {
		ValueObservation
			.tracking { db in
				try TrackVersion.filter(Column("trackID") == track?.id).order(literal: "number DESC").fetchAll(db)
			}
		// The `.immediate` scheduling feeds the view right on subscription,
		// and avoids an initial rendering with an empty list:
		.publisher(in: dbQueue, scheduling: .immediate)
		.eraseToAnyPublisher()
	}
}

public struct TrackVersionsProvider<Content: View>: View {
	var track: Track
	var content: ([TrackVersion]) -> Content

	@Query(TrackVersionsRequest(), in: \.dbQueue) var versions: [TrackVersion]

	public init(track: Track, content: @escaping ([TrackVersion]) -> Content) {
		self.track = track
		self.content = content
		self._versions = Query(TrackVersionsRequest(track: track), in: \.dbQueue)
	}

	public var body: some View {
		content(versions)
	}
}

#Preview {
	DBProvider(.memory) {
		ClientProvider {
			TrackVersionsProvider(track: Track.list[0]) { _ in
				Text("Hi")
			}
		}
	}
}
