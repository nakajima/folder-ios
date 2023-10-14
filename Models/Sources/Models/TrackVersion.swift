//
//  TrackVersion.swift
//
//
//  Created by Pat Nakajima on 10/5/23.
//

import GRDB
import Foundation

public struct TrackVersion: Model {
	public var id: Int
	public var nodeID: String
	public var duration: Int?
	public var number: Int
	public var trackID: Int
	public var uuid: String
	public var isCurrent: Bool
	public var status: VersionDownloader.State = .unknown

	public var downloadURL: URL {
		VersionDownloader.downloadsURL.appendingPathComponent("\(uuid).mp3")
	}

	public func track(in queue: DatabaseQueue) async throws -> Track? {
		try await queue.read { db in
			try Track.fetchOne(db, key: trackID)
		}
	}
}
