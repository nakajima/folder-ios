//
//  TrackShowView.swift
//  folder-ios
//
//  Created by Pat Nakajima on 10/3/23.
//

import Models
import pat_swift
import SwiftUI

struct TrackShowView: View {
	@Namespace var namespace
	@EnvironmentObject var playerSession: PlayerSession
	@EnvironmentObject var pathManager: PathManager

	@State private var isShowingCover = false

	var track: Track

	var body: some View {
		GeometryReader { geo in
			ZStack {
				List {
					Section {
						HStack(spacing: 12) {
							NeonView(size: 48, seed: track.id)
								.cornerRadius(Constants.cornerRadius)
								.shadow(radius: 2)
								.overlay {
									if !isShowingCover {
										Color.clear
											.contentShape(Rectangle())
											.matchedGeometryEffect(id: "cover", in: namespace)
									}
								}
								.onTapGesture {
									withAnimation(.spring(duration: 0.2)) {
										isShowingCover.toggle()
									}
								}

							Text(track.name)
								.font(.title3)
								.bold()
								.lineSpacing(-1)
								.multilineTextAlignment(.leading)
							Spacer()
						}
						.frame(maxWidth: .infinity)
						.padding()
						.background(.ultraThinMaterial)
						.cornerRadius(Constants.cornerRadius)
						.listRowSeparator(.hidden)
					}

					VStack(spacing: 12) {
						TrackVersionsProvider(track: track) { versions in
							ForEach(versions) { version in
								HStack(spacing: 8) {
									PlayButton(track: track, version: version)

									Text("Version \(version.number)")
										.bold()

									if version.isCurrent {
										Text("Current")
											.font(.caption2)
											.padding(.horizontal, 4)
											.padding(.vertical, 2)
											.background(.ultraThinMaterial)
											.cornerRadius(Constants.cornerRadius)
									}

									Spacer()

									Text("0 comments")
										.foregroundStyle(.secondary)
								}
								.foregroundStyle(version.status == .downloaded ? .primary : .secondary)
								.listRowSeparator(.hidden)

								if version.number != 1 {
									Divider()
										.listRowSeparator(.hidden)
								}
							}
						}
						.listRowSeparator(.hidden)
					}
					.font(.subheadline)
					.frame(maxWidth: .infinity)
					.padding(12)
					.background(.ultraThinMaterial)
					.cornerRadius(Constants.cornerRadius)
					.listRowSeparator(.hidden)

					TrackFoldersProvider(track: track) { folders in
						TagStackView(spacing: 4) {
							Text("Folders:")
								.font(.caption)
								.padding(.vertical, 4)

							if folders.isEmpty {
								Text("None")
									.padding(.vertical, 4)
									.font(.caption)
									.foregroundStyle(.secondary)
							}

							ForEach(folders) { folder in
								Text(folder.name)
									.padding(.horizontal, 8)
									.padding(.vertical, 4)
									.font(.caption)
									.background(.ultraThinMaterial)
									.cornerRadius(Constants.cornerRadius)
									.bold()
									.onTapGesture {
										self.pathManager.append(.folder(folder))
									}
							}
						}
						.cornerRadius(Constants.cornerRadius)
						.listRowSeparator(.hidden)
						.padding(.top, 12)
					}

					TrackTagsProvider(track: track) { tags in
						TagStackView {
							ForEach(tags) { tag in
								Text(tag.name)
									.padding(.horizontal, 8)
									.padding(.vertical, 4)
									.background(.ultraThinMaterial)
									.cornerRadius(Constants.cornerRadius)
									.font(.caption)
							}
						}
						.listRowSeparator(.hidden)
					}

					if playerSession.nowPlaying != nil {
						Spacer()
							.frame(height: 128)
							.listRowSeparator(.hidden)
					}
				}
				.listStyle(.plain)

				if isShowingCover {
					VStack(spacing: 8) {
						NeonView(size: geo.size.width - 24, seed: track.id)
							.cornerRadius(Constants.cornerRadius)
						Text("Hey this cover art is random.")
							.font(.caption)
					}
					.padding(12)
					.transition(.move(edge: .top).combined(with: .opacity))
					.background(.ultraThinMaterial)
					.cornerRadius(Constants.cornerRadius)
					.dragDismissable {
						withAnimation(.spring(duration: 0.2)) {
							isShowingCover = false
						}
					}
				}
			}
		}
	}
}

#Preview {
	DBProvider(.memory) {
		ClientProvider {
			NavigationStack {
				TrackListView()
			}
		}
	}
}
