// The Swift Programming Language
// https://docs.swift.org/swift-book

import GRDB
import Foundation
import pat_swift

public struct Track: Model {
	public var id: Int
	public var nodeID: String
	public var name: String
	public var updatedAt: Date
	public var shareURL: URL
	public var currentVersionID: Int?
	public var analyzedAt = Date.distantPast

	public init(id: Int, nodeID: String, name: String, updatedAt: Date, shareURL: URL) {
		self.id = id
		self.nodeID = nodeID
		self.name = name
		self.updatedAt = updatedAt
		self.shareURL = shareURL
	}

	public func downloadLatestVersion(from queue: DatabaseQueue, with client: ApiClient) async -> VersionDownloader? {
		guard let version = await latestVersion(from: queue) else {
			return nil
		}

		return VersionDownloader(client: client, queue: queue, trackVersion: version)
	}

	public func latestVersion(from queue: DatabaseQueue) async -> TrackVersion? {
		return await Log.catch("Error getting latest version") {
			return try await queue.read { db in
				try TrackVersion.filter(Column("trackID") == self.id && Column("isCurrent") == true).fetchOne(db)
			}
		}
	}

	public mutating func analyze(queue: DatabaseQueue) async throws {
		if analyzedAt > updatedAt {
			return
		}

		guard let version = await latestVersion(from: queue),
		      version.status == .downloaded
		else {
			return
		}

		try await Analyzer(database: queue, track: self, version: version).start()

		analyzedAt = Date()

		try await save(to: queue)
	}
}

public extension Track {
	static let list: [Track] = [
		.init(id: 1, nodeID: "1", name: "onmyown", updatedAt: Date(), shareURL: URL(string: "https://folder.fm/share")!),
	]
}
