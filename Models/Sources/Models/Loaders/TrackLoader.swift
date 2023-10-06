//
//  TrackLoader.swift
//  folder-ios
//
//  Created by Pat Nakajima on 10/5/23.
//

import Foundation
import pat_swift
import API

public actor TrackLoader {
	var database: Models.Database
	var client: ApiClient

	init(database: Models.Database, client: ApiClient) {
		self.database = database
		self.client = client
	}

	public func downloadLatestVersions() async {
		await Log.catch("Error downloading latest versions") {
			for tracks in try await Track.read(from: self.database, orderBy: .descending(\.$updatedAt)).chunked(into: 5) {
				await withTaskGroup(of: Void.self) { group in
					for track in tracks {
						group.addTask { [self] in
							await track.downloadLatestVersion(from: database, with: client)?.download()
						}
					}

					await group.waitForAll()
				}
			}
		}
	}

	public func load() async {
		let tracks = await Log.catch("Error fetching tracks") { [self] in
			try await client.fetch(TrackLoaderQuery())
		}

		for edge in tracks?.viewer?.feedTracks?.edges ?? [] where edge != nil {
			guard let node = edge?.node,
						let id = Int(node.id) else { continue }

			await Log.catch("Error saving track \(node)") { [self] in
				var track = try await Track.read(from: database, id: id) ?? Track(
					id: id,
					nodeID: node.nodeID,
					name: node.name,
					updatedAt: node.updatedAt,
					shareURL: URL(string: node.shareUrl)!
				)

				track.name = node.name
				track.updatedAt = node.updatedAt
				track.shareURL = URL(string: node.shareUrl)!

				try await track.write(to: database)

				for versionNode in (node.versions.edges ?? []).compactMap({ $0?.node }) {
					guard let id = Int(versionNode.id) else { continue }

					let version = try await TrackVersion.read(from: database, id: id) ?? TrackVersion(
						id: id,
						nodeID: versionNode.node_id,
						duration: versionNode.duration,
						number: versionNode.number,
						trackID: track.id,
						uuid: versionNode.uuid,
						isCurrent: versionNode.isCurrent
					)

					try await version.write(to: database)

					if version.isCurrent {
						track.currentVersionID = version.id
						try await track.write(to: database)
					}
				}
			}
		}
	}
}
