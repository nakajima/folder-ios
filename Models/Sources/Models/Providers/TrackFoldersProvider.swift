//
//  TrackFoldersProvider.swift
//
//
//  Created by Pat Nakajima on 10/6/23.
//

import SwiftUI
import GRDB
import GRDBQuery
import Combine

struct TrackFoldersRequest: Queryable {
	static var defaultValue: [Folder] = []
	var track: Track?

	func publisher(in dbQueue: DatabaseQueue) -> AnyPublisher<[Folder], Error> {
		ValueObservation
			.tracking { db in
				return []
			}
		// The `.immediate` scheduling feeds the view right on subscription,
		// and avoids an initial rendering with an empty list:
		.publisher(in: dbQueue, scheduling: .immediate)
		.eraseToAnyPublisher()
	}
}

public struct TrackFoldersProvider<Content: View>: View {
	var track: Track
	var content: ([Folder]) -> Content

	@Query(TrackFoldersRequest(), in: \.dbQueue) var folders: [Folder]

	public init(track: Track, content: @escaping ([Folder]) -> Content) {
		self.track = track
		self.content = content
		self._folders = Query(TrackFoldersRequest(track: track), in: \.dbQueue)
	}

	public var body: some View {
		content(folders)
	}
}
