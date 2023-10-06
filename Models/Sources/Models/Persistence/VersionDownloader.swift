//
//  VersionDownloader.swift
//
//
//  Created by Pat Nakajima on 10/5/23.
//

import Foundation
import API
import pat_swift
import Blackbird

public class VersionDownloader: NSObject, URLSessionDataDelegate {
	public enum State: Int64, BlackbirdColumnWrappable, BlackbirdStorableAsInteger, Codable {
		public static func fromValue(_ value: Blackbird.Value) -> State? {
			switch value {
			case let .integer(int):
				return from(unifiedRepresentation: int)
			default:
				fatalError("Wrong status")
			}
		}

		public func unifiedRepresentation() -> Int64 {
			rawValue
		}

		public static func from(unifiedRepresentation: Int64) -> State {
			State(rawValue: unifiedRepresentation)!
		}

		case unknown, downloading, downloaded
	}

	var client: ApiClient
	var database: Database
	var trackVersion: TrackVersion

	@Published public  var status: State = .unknown

	static var downloadsURL: URL {
		URL.documentsDirectory.appendingPathComponent("downloads")
	}

	static func setup() {
		try? FileManager.default.createDirectory(at: downloadsURL, withIntermediateDirectories: true)
	}

	init(client: ApiClient, database: Database, trackVersion: TrackVersion) {
		self.client = client
		self.database = database
		self.trackVersion = trackVersion
	}

	public var downloadedURL: URL {
		trackVersion.downloadURL
	}

	public func markDownloaded() async {
		await Log.catch("Error marking as downloaded") {
			var trackVersion = self.trackVersion
			trackVersion.status = .downloaded
			try await trackVersion.write(to: self.database)
		}
	}

	public func download() async {
		VersionDownloader.setup()

		if FileManager.default.fileExists(atPath: downloadedURL.path) {
			await markDownloaded()
			return
		}

		await Log.catch("Error downloading") {
			self.trackVersion.status = .downloaded
			try await self.trackVersion.write(to: self.database)

			guard let remoteURLString = try await self.client.fetch(GetTrackVersionDownloadURLQuery(dbid: "\(self.trackVersion.id)")).viewer?.trackVersionDownloadURL,
						let remoteURL = URL(string: remoteURLString) else {
				return
			}

			let session = URLSession(configuration: .ephemeral, delegate: self, delegateQueue: .main)
			let request = URLRequest(url: remoteURL)

			let (data, _) = try await session.data(for: request)

			try data.write(to: self.downloadedURL)

			await self.markDownloaded()
		}
	}
}
