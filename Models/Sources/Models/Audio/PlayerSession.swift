//
//  PlayerSession.swift
//  
//
//  Created by Pat Nakajima on 10/6/23.
//

import Foundation
import AVFAudio
import pat_swift
import MediaPlayer
import SwiftUI

public class PlayerSession: NSObject, ObservableObject, AVAudioPlayerDelegate {
	@Published public var nowPlaying: NowPlaying?

	var audioPlayerCore: AudioPlayerCore!
	var timer: Timer?
	public var playlist: Playlist?

	override public init() {
		Log.catch("Error setting up audio session") {
			try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.allowBluetooth, .allowAirPlay])
			try AVAudioSession.sharedInstance().setActive(true)
		}

		super.init()

		self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
			Task(priority: .medium) {
				await self.sync()
			}
		}

		self.audioPlayerCore = AudioPlayerCore(delegate: self)

		setupCommandCenter()
	}

	@objc func update() {
		Task(priority: .medium) {
			await self.sync()
		}
	}

	public func scrub(to normalized: Double) {
		guard let nowPlaying, let duration = nowPlaying.version.duration else {
			return
		}

		let newTime = Double(duration) * normalized
		self.nowPlaying?.currentTime = newTime

		Task(priority: .userInitiated) {
			await audioPlayerCore.scrub(to: newTime)
		}
	}

	public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
		next()
	}

	public func previous() {
		Task(priority: .userInitiated) {
			if let nowPlaying, nowPlaying.currentTime > 3 {
				let audioPlayer = await audioPlayerCore.audioPlayer
				audioPlayer?.currentTime = 0
				return
			}

			if let (track, version) = await playlist?.previous(current: nowPlaying) {
				await play(track: track, version: version)
			}
		}
	}

	public func next() {
		Task(priority: .userInitiated) {
			Task(priority: .userInitiated) {
				if let (track, version) = await playlist?.next(current: nowPlaying) {
					await play(track: track, version: version)
				}
			}
		}
	}

	public var isPlaying: Bool {
		nowPlaying?.isPlaying ?? false
	}

	public func toggle(track: Track, version: TrackVersion) {
		Task(priority: .userInitiated) {
			if let nowPlaying {
				if nowPlaying.track != track || nowPlaying.version != version {
					await play(track: track, version: version)
					return
				}
			}

			if isPlaying {
				await pause()
			} else {
				await play(track: track, version: version)
			}
		}
	}

	public func play() async {
		await audioPlayerCore.audioPlayer?.play()
	}

	public func play(track: Track, version: TrackVersion) async {
		await audioPlayerCore.play(url: version.downloadURL, preserveTime: nowPlaying?.track == track)

		if let nowPlaying, nowPlaying.track == track, nowPlaying.version == version {
			return
		}

		await MainActor.run {
			withAnimation(.spring(duration: 0.4)) {
				nowPlaying = .init(track: track, version: version)
			}
		}

		await sync()
	}

	public func play(version: TrackVersion, from db: Database) async {
		guard let track = try! await version.track(in: db) else {
			return
		}

		await play(track: track, version: version)
	}

	public func pause() async {
		await audioPlayerCore.pause()
		await sync()
	}

	public func sync() async {
		guard var newNowPlaying = nowPlaying else {
			return
		}

		newNowPlaying.isPlaying = await audioPlayerCore.isPlaying
		newNowPlaying.currentTime = await audioPlayerCore.currentTime

		let nowPlaying = newNowPlaying

		self.refreshNowPlaying()

		await MainActor.run {
			self.nowPlaying = nowPlaying
		}
	}

	private func refreshNowPlaying() {
		guard let nowPlaying else { return }

		MPNowPlayingInfoCenter.default().nowPlayingInfo = [
			MPMediaItemPropertyTitle: nowPlaying.track.name,
			MPMediaItemPropertyAlbumTitle: "Version \(nowPlaying.version.number)",
			MPMediaItemPropertyPlaybackDuration: nowPlaying.version.duration ?? 0,
			MPNowPlayingInfoPropertyElapsedPlaybackTime: nowPlaying.currentTime,
		]
	}

	// Needed to put stuff into controller center
	private func setupCommandCenter() {
		MPNowPlayingInfoCenter.default().nowPlayingInfo = [MPMediaItemPropertyTitle: "folder.fm"]

		let commandCenter = MPRemoteCommandCenter.shared()
		commandCenter.playCommand.isEnabled = true
		commandCenter.pauseCommand.isEnabled = true
		commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event -> MPRemoteCommandHandlerStatus in
			if let event = event as? MPChangePlaybackPositionCommandEvent {
				self?.scrub(to: event.positionTime)
			}

			return .success
		}

		commandCenter.playCommand.addTarget { [weak self] _ -> MPRemoteCommandHandlerStatus in
			Task(priority: .userInitiated) { [weak self] in
				await self?.play()
			}

			return .success
		}

		commandCenter.pauseCommand.addTarget { [weak self] _ -> MPRemoteCommandHandlerStatus in
			self?.previous()

			return .success
		}

		commandCenter.nextTrackCommand.addTarget { [weak self] _ -> MPRemoteCommandHandlerStatus in
			self?.next()

			return .success
		}

		commandCenter.previousTrackCommand.addTarget { _ -> MPRemoteCommandHandlerStatus in
			Task(priority: .userInitiated) { [weak self] in
				guard let playlist = self?.playlist else { return }

				if let (track, version) = await playlist.previous(current: self?.nowPlaying) {
					await self?.play(track: track, version: version)
				}
			}
			return .success
		}
	}
}
