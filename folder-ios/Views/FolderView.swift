//
//  FolderView.swift
//  folder-ios
//
//  Created by Pat Nakajima on 10/6/23.
//

import Models
import SwiftUI

struct FolderView: View {
	var folder: Folder

	var body: some View {
		FolderTracksProvider(folder: folder) { tracks in
			List {
				ForEach(tracks) { track in
					NavigationLink(destination: TrackShowView(track: track)) {
						TrackListCellView(track: track)
					}
					.listRowSeparator(.automatic)
					.listRowInsets(.init())
					.listRowBackground(Color.clear)
				}

				Spacer()
					.frame(height: 64)
					.listRowBackground(Color.clear)
			}
			.safeAreaInset(edge: .top) {
				HStack {
					Text(folder.name)
					Spacer()
					Image(systemName: "folder.fill")
						.foregroundColor(.secondary)
				}
				.padding()
				.font(.title3)
				.background(
					Rectangle()
						.fill(.ultraThinMaterial)
						.shadow(radius: 1)
				)
			}
		}
	}
}
