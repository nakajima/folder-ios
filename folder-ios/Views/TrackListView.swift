//
//  TrackListView.swift
//  folder-ios
//
//  Created by Pat Nakajima on 10/3/23.
//

import SwiftUI

struct TrackListView: View {
	var body: some View {
		List {
			ForEach(Track.list) { track in
				NavigationLink(destination: TrackShowView(track: track)) {
					TrackListCellView(track: track)
				}
			}
			Spacer()
				.frame(height: 64)
		}
		.listStyle(.plain)
		.navigationBarTitleDisplayMode(.inline)
		.navigationTitle("Home")
	}
}

#Preview {
	ContentView()
}
