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
	@Environment(\.blackbirdDatabase) var database

	var body: some View {
		TracksProvider { loader, tracks in
			List {
				ForEach(tracks) { track in
					TrackVersionProvider(track: track) { version in
						Button(action: {
							pathManager.append(.track(track))
							Task(priority: .userInitiated) {
								await playerSession.play(
									track: track,
									version: version
								)
							}
						}) {
							TrackListCellView(track: track)
						}
						.tint(.primary)
						.listRowInsets(.init(top: 2, leading: 12, bottom: 2, trailing: 12))
						.listRowBackground(Color.clear)
					}
					.swipeActions {
						Button(action: {
							pathManager.append(.track(track))
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
			.navigationBarTitleDisplayMode(.inline)
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
