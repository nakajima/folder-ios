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

struct FolderTracksRequest: Queryable {
	static var defaultValue: [TrackWithCurrentVersion] = []
	var folder: Folder?

	func publisher(in dbQueue: DatabaseQueue) -> AnyPublisher<[TrackWithCurrentVersion], Error> {
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


public struct FolderTracksProvider<Content: View>: View {
	var folder: Folder
	var content: ([TrackWithCurrentVersion]) -> Content

	@Query(FolderTracksRequest(), in: \.dbQueue) var tracks: [TrackWithCurrentVersion]

	public init(folder: Folder, content: @escaping ([TrackWithCurrentVersion]) -> Content) {
		self.folder = folder
		self.content = content
		self._tracks = Query(FolderTracksRequest(folder: folder), in: \.dbQueue)
	}

	public var body: some View {
		content(tracks)
	}
}
