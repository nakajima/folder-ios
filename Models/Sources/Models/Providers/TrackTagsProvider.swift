//
//  TrackTagsProvider.swift
//
//
//  Created by Pat Nakajima on 10/6/23.
//

import Foundation
import SwiftUI

public struct TrackTagsProvider<Content: View>: View {
	@Environment(\.blackbirdDatabase) var db

	var track: Track
	var content: ([Tag]) -> Content

	public init(track: Track, content: @escaping ([Tag]) -> Content) {
		self.track = track
		self.content = content
	}

	@State private var tags = Tag.LiveResults()
	private var tagsUpdater = Tag.ArrayUpdater()

	public var body: some View {
		content(tags.results)
			.onAppear {
				tagsUpdater.bind(from: db, to: $tags) {
					try await Tag.read(from: $0, sqlWhere: "trackID = ?", track.id)
				}
			}
	}
}
