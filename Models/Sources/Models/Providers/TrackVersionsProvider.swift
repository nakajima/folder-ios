//
//  TrackVersionsProvider.swift
//
//
//  Created by Pat Nakajima on 10/5/23.
//

import SwiftUI
import Blackbird

public struct TrackVersionsProvider<Content: View>: View {
	var database: Database
	var track: Track
	var content: (TrackVersion) -> Content

	@State public var versions = TrackVersion.LiveResults()
	var versionsUpdater = TrackVersion.ArrayUpdater()

	public init(database: Database, track: Track, content: @escaping (TrackVersion) -> Content) {
		self.database = database
		self.track = track
		self.content = content
	}

	public var body: some View {
		ForEach(versions.results) { result in
			content(result)
		}
		.onAppear {
			versionsUpdater.bind(from: database, to: $versions) {
				try await TrackVersion.read(from: $0, sqlWhere: "trackID = ?", track.id)
			}
		}
	}
}

#Preview {
	DBProvider(.memory) {
		ClientProvider {
			TrackVersionsProvider(database: try! Database.inMemoryDatabase(), track: Track.list[0]) { _ in
				Text("Hi")
			}
		}
	}
}
