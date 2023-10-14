//
//  TrackListView.swift
//  folder-ios
//
//  Created by Pat Nakajima on 10/3/23.
//

import Models
import SwiftUI

struct TrackListView: View {
	@EnvironmentObject var playerSession: PlayerSession
	@EnvironmentObject var pathManager: PathManager

	var body: some View {
		TracksProvider { loader, tracksWithCurrentVersion in
			List {
				ForEach(tracksWithCurrentVersion) { trackWithCurrentVersion in
					Button(action: {
						pathManager.append(.track(trackWithCurrentVersion.track))
						Task(priority: .userInitiated) {
							await playerSession.play(
								track: trackWithCurrentVersion.track,
								version: trackWithCurrentVersion.currentVersion
							)
						}
					}) {
						TrackListCellView(trackWithCurrentVersion: trackWithCurrentVersion)
					}
					.tint(.primary)
					.listRowInsets(.init(top: 16, leading: 12, bottom: 16, trailing: 12))
					.listRowBackground(Color.clear)
					.swipeActions {
						Button(action: {
							pathManager.append(.track(trackWithCurrentVersion.track))
						}) {
							Text("View")
						}
						.tint(.primary)
					}
				}
				Spacer()
					.frame(height: 64)
					.listRowSeparator(.hidden)
					.listRowBackground(Color.clear)
			}
			.listStyle(.plain)
			#if os(iOS)
			.navigationBarTitleDisplayMode(.inline)
			#endif
			.navigationTitle("Home")
			.task {
				await loader.load()

				Task.detached {
					await loader.downloadLatestVersions()
				}
			}
			.refreshable {
				await loader.load()

				Task.detached {
					await loader.downloadLatestVersions()
				}
			}
		}
	}
}

#Preview {
	ContentView()
}
