//
//  TrackListCellView.swift
//  folder-ios
//
//  Created by Pat Nakajima on 10/4/23.
//

import Models
import SwiftUI

struct TrackListCellView: View {
	var trackWithCurrentVersion: TrackWithCurrentVersion

	var body: some View {
		HStack {
			ZStack(alignment: .center) {
				NeonView(size: 36, seed: trackWithCurrentVersion.track.id)
					.cornerRadius(Constants.cornerRadius)

				PlayButton(track: trackWithCurrentVersion.track, version: trackWithCurrentVersion.currentVersion)
					.foregroundStyle(.white)
			}

			VStack(alignment: .leading) {
				HStack(alignment: .firstTextBaseline) {
					Text(trackWithCurrentVersion.track.name)
						.font(.subheadline)
						.bold()
					Spacer()
				}

				HStack(spacing: 4) {
					Group {
						switch trackWithCurrentVersion.currentVersion.status {
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

					Spacer()
				}
				.foregroundStyle(.secondary)
				.font(.caption)
			}
		}
	}
}
