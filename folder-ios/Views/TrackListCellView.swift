//
//  TrackListCellView.swift
//  folder-ios
//
//  Created by Pat Nakajima on 10/4/23.
//

import Models
import SwiftUI

struct TrackListCellView: View {
	var track: Track

	var body: some View {
		HStack {
			ZStack(alignment: .center) {
				NeonView(size: 36, seed: track.id)
					.cornerRadius(Constants.cornerRadius)

				TrackVersionProvider(track: track) { version in
					PlayButton(track: track, version: version)
				}
				.foregroundStyle(.white)
			}

			VStack(alignment: .leading) {
				HStack(alignment: .firstTextBaseline) {
					Text(track.name)
						.font(.subheadline)
						.bold()
					Spacer()
				}

				HStack(spacing: 4) {
					//					Text(track.duration.formatDuration)
					//						.font(.caption)
					TrackVersionProvider(track: track) { version in
						Group {
							switch version.status {
							case .unknown:
								Text("Unsynced")
								Image(systemName: "exclamationmark.arrow.triangle.2.circlepath")
							case .downloading:
								Text("Syncing…")
								Image(systemName: "arrow.down.app")
							case .downloaded:
								Text("Synced")
								Image(systemName: "checkmark.circle")
							}
						}
					}

					Spacer()
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
