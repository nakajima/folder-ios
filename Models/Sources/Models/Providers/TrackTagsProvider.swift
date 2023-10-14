//
//  TrackTagsProvider.swift
//
//
//  Created by Pat Nakajima on 10/6/23.
//

import Foundation
import SwiftUI
import GRDB
import GRDBQuery
import Combine

struct TrackTagsRequest: Queryable {
	static var defaultValue: [Tag] = []
	var track: Track?

	func publisher(in dbQueue: DatabaseQueue) -> AnyPublisher<[Tag], Error> {
		ValueObservation
			.tracking { db in
				try Tag.filter(Column("trackID") == track?.id).fetchAll(db)
			}
		// The `.immediate` scheduling feeds the view right on subscription,
		// and avoids an initial rendering with an empty list:
		.publisher(in: dbQueue, scheduling: .immediate)
		.eraseToAnyPublisher()
	}
}

public struct TrackTagsProvider<Content: View>: View {
	var track: Track
	var content: ([Tag]) -> Content

	@Query(TrackTagsRequest(), in: \.dbQueue) var tags: [Tag]

	public init(track: Track, content: @escaping ([Tag]) -> Content) {
		self.track = track
		self.content = content
		self._tags = Query(TrackTagsRequest(track: track), in: \.dbQueue)
	}

	public var body: some View {
		content(tags)
	}
}
