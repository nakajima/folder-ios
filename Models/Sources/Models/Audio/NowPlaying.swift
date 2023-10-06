//
//  NowPlaying.swift
//
//
//  Created by Pat Nakajima on 10/6/23.
//

import Foundation

public struct NowPlaying: Identifiable, Equatable {
	public var id: String {
		"\(track.id)-\(version.id)"
	}

	public var track: Track
	public var version: TrackVersion
	public var isPlaying = false
	public var currentTime: TimeInterval = 0
}
