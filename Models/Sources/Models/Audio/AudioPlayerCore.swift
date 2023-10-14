//
//  AudioPlayerCore.swift
//
//
//  Created by Pat Nakajima on 10/6/23.
//

import AVFAudio
import pat_swift
#if canImport(UIKit)
import UIKit
#else
import AppKit
#endif

actor AudioPlayerCore {
	var audioPlayer: AVAudioPlayer?
	var delegate: PlayerSession?

	init(delegate: PlayerSession) {
		self.delegate = delegate

		#if canImport(UIKit)
		Task {
			await MainActor.run {
				UIApplication.shared.beginReceivingRemoteControlEvents()
			}
		}
		#endif
	}

	var isPlaying: Bool {
		audioPlayer?.isPlaying ?? false
	}

	var currentTime: TimeInterval {
		audioPlayer?.currentTime ?? 0
	}

	func scrub(to time: TimeInterval) {
		audioPlayer?.currentTime = time
	}

	func play(url: URL, preserveTime: Bool = false) {
		let time = currentTime

		load(url: url)

		guard let audioPlayer else {
			return
		}

		if preserveTime {
			audioPlayer.currentTime = time
		}

		audioPlayer.play()
	}

	func pause() {
		audioPlayer?.pause()
	}

	func load(url: URL) {
		if audioPlayer?.url == url {
			return
		}

		audioPlayer?.delegate = delegate

		Log.catch("Error loading URL \(url)") {
			self.audioPlayer = try AVAudioPlayer(contentsOf: url)
			self.audioPlayer?.prepareToPlay()
		}
	}
}
