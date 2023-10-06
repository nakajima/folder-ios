// The Swift Programming Language
// https://docs.swift.org/swift-book

import Blackbird
import Foundation
import pat_swift

public struct Track: BlackbirdModel, Equatable {
	@BlackbirdColumn public var id: Int
	@BlackbirdColumn public var nodeID: String
	@BlackbirdColumn public var name: String
	@BlackbirdColumn public var updatedAt: Date
	@BlackbirdColumn public var shareURL: URL
	@BlackbirdColumn public var currentVersionID: Int?
	@BlackbirdColumn public var analyzedAt = Date.distantPast

	public init(id: Int, nodeID: String, name: String, updatedAt: Date, shareURL: URL) {
		self.id = id
		self.nodeID = nodeID
		self.name = name
		self.updatedAt = updatedAt
		self.shareURL = shareURL
	}

	public func downloadLatestVersion(from db: Database, with client: ApiClient) async -> VersionDownloader? {
		guard let version = await latestVersion(from: db) else {
			return nil
		}

		return VersionDownloader(client: client, database: db, trackVersion: version)
	}

	public func latestVersion(from db: Database) async -> TrackVersion? {
		return await Log.catch("Error getting latest version") {
			let version = try await TrackVersion.read(from: db, sqlWhere: "trackID = ? AND isCurrent = ?", id, true).first
			return version
		}
	}

	public mutating func analyze(database: Database) async throws {
		if analyzedAt > updatedAt {
			return
		}

		guard let version = await latestVersion(from: database),
					version.status == .downloaded else {
			return
		}

		try await Analyzer(database: database, track: self, version: version).start()

		analyzedAt = Date()

		try await write(to: database)
	}
}

public extension Track {
	static let list: [Track] = [
		.init(id: 1, nodeID: "1", name: "onmyown", updatedAt: Date(), shareURL: URL(string: "https://folder.fm/share")!),
	]
}
