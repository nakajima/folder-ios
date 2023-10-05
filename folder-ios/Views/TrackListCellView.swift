//
//  TrackListCellView.swift
//  folder-ios
//
//  Created by Pat Nakajima on 10/4/23.
//

import SwiftUI

struct TrackListCellView: View {
	var track: Track

	var body: some View {
		HStack {
			ZStack(alignment: .center) {
				NeonView(size: 36, seed: track.id)
					.cornerRadius(Constants.cornerRadius)

				Button(action: {}) {
					Label("Play", systemImage: "play.circle")
						.labelStyle(.iconOnly)
						.foregroundStyle(Color.white)
				}
				.shadow(radius: 2)
			}

			VStack(alignment: .leading) {
				HStack(alignment: .firstTextBaseline) {
					Text(track.name)
						.font(.subheadline)
						.bold()
					Spacer()
				}

				HStack(spacing: 4) {
					Text(track.duration.formatDuration)
						.font(.caption)
					Spacer()
					Text("Synced")
					Image(systemName: "checkmark.circle")
				}
				.foregroundStyle(.secondary)
				.font(.caption)
			}
		}
	}
}

#Preview {
	NavigationStack {
		List {
			TrackListCellView(track: Track.list[0])
		}
		.listStyle(.plain)
		.navigationTitle("Home")
	}
}
