//
//  TrackFoldersProvider.swift
//
//
//  Created by Pat Nakajima on 10/6/23.
//

import SwiftUI

public struct TrackFoldersProvider<Content: View>: View {
	@Environment(\.blackbirdDatabase) var database

	var track: Track
	var content: ([Folder]) -> Content

	@State private var folders = Folder.LiveResults()
	private var foldersUpdater = Folder.ArrayUpdater()

	public init(track: Track, content: @escaping ([Folder]) -> Content) {
		self.track = track
		self.content = content
	}

	public var body: some View {
		content(folders.results)
			.onAppear {
				foldersUpdater.bind(from: database!, to: $folders) {
					await Folder.list(track: track, in: $0)
				}
			}
	}
}
