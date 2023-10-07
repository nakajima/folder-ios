//
//  FolderTracksProvider.swift
//
//
//  Created by Pat Nakajima on 10/6/23.
//

import SwiftUI

public struct FolderTracksProvider<Content: View>: View {
	@Environment(\.blackbirdDatabase) var database

	var folder: Folder
	var content: ([Track]) -> Content

	@State private var tracks = Track.LiveResults()
	private var tracksUpdater = Track.ArrayUpdater()

	public init(folder: Folder, content: @escaping ([Track]) -> Content) {
		self.folder = folder
		self.content = content
	}

	public var body: some View {
		content(tracks.results)
			.onAppear {
				tracksUpdater.bind(from: database!, to: $tracks) {
					let tracks = await Folder.list(folder: folder, in: $0)

					return tracks.sorted(by: { t1, t2 in
						let orderedTrackIDs = folder.orderedTrackIDs.split(separator: "\t").map { String($0) }

						let a = orderedTrackIDs.firstIndex(where: { t in t == t1.nodeID }) ?? 0
						let b = orderedTrackIDs.firstIndex(where: { t in t == t2.nodeID }) ?? 0

						return a < b
					})
				}
			}
	}
}
