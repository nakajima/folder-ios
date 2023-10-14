//
//  VersionDownloader.swift
//
//
//  Created by Pat Nakajima on 10/5/23.
//

import API
import GRDB
import Foundation
import pat_swift

public class VersionDownloader: NSObject, ObservableObject, URLSessionDataDelegate {
	public enum State: String, Codable {
		case unknown, downloading, downloaded
	}

	var client: ApiClient
	var queue: DatabaseQueue
	var trackVersion: TrackVersion

	@Published public var status: State = .unknown

	static var downloadsURL: URL {
		URL.documentsDirectory.appendingPathComponent("downloads")
	}

	static func setup() {
		try? FileManager.default.createDirectory(at: downloadsURL, withIntermediateDirectories: true)
	}

	init(client: ApiClient, queue: DatabaseQueue, trackVersion: TrackVersion) {
		self.client = client
		self.queue = queue
		self.trackVersion = trackVersion
	}

	public var downloadedURL: URL {
		trackVersion.downloadURL
	}

	public func markDownloaded() async {
		await Log.catch("Error marking as downloaded") {
			try await self.queue.write { db in
				var trackVersion = self.trackVersion
				trackVersion.status = .downloaded
				try trackVersion.save(db)
			}
		}
	}

	public func download() async {
		VersionDownloader.setup()

		if FileManager.default.fileExists(atPath: downloadedURL.path) {
			await markDownloaded()
			return
		}

		await Log.catch("Error downloading") {
			self.trackVersion.status = .downloading
			try await self.trackVersion.save(to: self.queue)

			guard let remoteURLString = try await self.client.fetch(GetTrackVersionDownloadURLQuery(dbid: "\(self.trackVersion.id)")).viewer?.trackVersionDownloadURL,
			      let remoteURL = URL(string: remoteURLString)
			else {
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
