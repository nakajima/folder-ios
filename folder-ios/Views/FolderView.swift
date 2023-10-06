//
//  FolderView.swift
//  folder-ios
//
//  Created by Pat Nakajima on 10/6/23.
//

import SwiftUI
import Models

struct FolderView: View {
	var folder: Folder

	var body: some View {
		NavigationStack {
			FolderTracksProvider(folder: folder) { tracks in
				List {
					ForEach(tracks) { track in
						NavigationLink(destination: TrackShowView(track: track)) {
							TrackListCellView(track: track)
						}
					}

					Spacer()
						.frame(height: 64)
						.listRowSeparator(.hidden)
				}
				.listStyle(.plain)
				.safeAreaInset(edge: .top) {
					HStack {
						Text(folder.name)
						Spacer()
						Image(systemName: "folder.fill")
							.foregroundColor(.secondary)
					}
					.padding()
					.font(.title3)
					.background(.ultraThinMaterial)
				}
			}
		}
	}
}
