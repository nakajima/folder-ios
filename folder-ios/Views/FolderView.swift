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
				VStack {
					HStack {
						Text(folder.name)
						Spacer()
						Image(systemName: "folder")
					}
					.padding()
					.font(.title)

					List {
						ForEach(tracks) { track in
							NavigationLink(destination: TrackShowView(track: track)) {
								TrackListCellView(track: track)
							}
						}
					}
					.listStyle(.plain)
				}
			}
		}
	}
}
