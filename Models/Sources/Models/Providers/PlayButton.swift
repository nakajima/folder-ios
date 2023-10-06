//
//  PlayButton.swift
//
//
//  Created by Pat Nakajima on 10/6/23.
//

import SwiftUI

public struct PlayButton: View {
	@EnvironmentObject var playerSession: PlayerSession
	@Environment(\.blackbirdDatabase) var database
	@Environment(\.apiClient) var apiClient

	public var track: Track
	@State public var version: TrackVersion?

	public var playIcon = "play.circle"
	public var pauseIcon = "pause.circle"
	public var size: CGFloat = 24

	public init(track: Track, version: TrackVersion? = nil, playIcon: String = "play.circle", pauseIcon: String = "pause.circle", size: CGFloat = 24) {
		self.track = track
		self._version = State(wrappedValue: version)
		self.playIcon = playIcon
		self.pauseIcon = pauseIcon
		self.size = size
	}

	public var body: some View {
		if let version {
			if version.status == .downloaded {
				Button(action: {
					playerSession.toggle(track: track, version: version)
				}) {
					Image(systemName: isPlaying ? pauseIcon : playIcon)
						.resizable()
						.scaledToFit()
						.frame(width: size, height: size)
				}
				.buttonStyle(.borderless)
			} else {
				if version.status == .downloading {
					ProgressView()
						.frame(width: size, height: size)
				} else {
					Button(action: {
						Task(priority: .userInitiated) {
							let downloader = VersionDownloader(client: apiClient, database: database!, trackVersion: version)
							
							await MainActor.run {
								self.version?.status = .downloading
							}

							await downloader.download()

							await MainActor.run {
								self.version?.status = .downloaded
							}

							await playerSession.play(track: track, version: version)
						}
					}) {
						Image(systemName: playIcon)
							.resizable()
							.scaledToFit()
							.frame(width: size, height: size)
							.opacity(0.5)
					}
					.buttonStyle(.borderless)
				}
			}
		} else {
			ProgressView()
				.task {
					guard let database,
								let version = try? await TrackVersion.read(
									from: database,
									id: track.currentVersionID
								) else { return }

					await MainActor.run {
						self.version = version
					}
				}
		}
	}

	var isPlaying: Bool {
		guard let nowPlaying = playerSession.nowPlaying else {
			return false
		}

		if nowPlaying.version.nodeID == version?.nodeID {
			return nowPlaying.isPlaying
		} else {
			return false
		}
	}
}
