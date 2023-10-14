//
//  TrackLoader.swift
//  folder-ios
//
//  Created by Pat Nakajima on 10/5/23.
//

import API
import Foundation
import GRDB
import pat_swift

public actor TrackLoader {
	var queue: DatabaseQueue
	var client: ApiClient

	init(queue: DatabaseQueue, client: ApiClient) {
		self.queue = queue
		self.client = client
	}

	public func downloadLatestVersions() async {
		await Log.catch("Error downloading latest versions") {
			let tracks = try await self.queue.read { db in
				try Track.order(literal: "updatedAt DESC").fetchAll(db)
			}

			for tracks in tracks.chunked(into: 5) {
				await withTaskGroup(of: Void.self) { group in
					for track in tracks {
						group.addTask { [self] in
							await track.downloadLatestVersion(from: queue, with: client)?.download()
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
				var track = try await Track.find(in: self.queue, key: id) ?? Track(
					id: id,
					nodeID: node.nodeID,
					name: node.name,
					updatedAt: node.updatedAt,
					shareURL: URL(string: node.shareUrl)!
				)

				track.name = node.name
				track.updatedAt = node.updatedAt
				track.shareURL = URL(string: node.shareUrl)!

				try await track.save(to: self.queue)

				for versionNode in (node.versions.edges ?? []).compactMap({ $0?.node }) {
					guard let id = Int(versionNode.id) else { continue }

					let version = try await TrackVersion.find(in: self.queue, key: id) ?? TrackVersion(
						id: id,
						nodeID: versionNode.node_id,
						duration: versionNode.duration,
						number: versionNode.number,
						trackID: track.id,
						uuid: versionNode.uuid,
						isCurrent: versionNode.isCurrent
					)

					try await version.save(to: self.queue)

					if version.isCurrent {
						track.currentVersionID = version.id
						try await track.save(to: self.queue)
					}
				}

				await Folder.clear(track: track, in: self.queue)

				for folderNode in node.folders.nodes ?? [] {
					guard let folderNode, let id = Int(folderNode.id) else {
						continue
					}

					let folder = Folder(
						id: id,
						nodeID: folderNode.nodeID,
						name: folderNode.name,
						orderedTrackIDs: folderNode.orderedTrackIDs.joined(separator: "\t")
					)

					try await folder.save(to: self.queue)

					await Folder.assign(track: track, to: folder, in: self.queue)
				}
			}
		}
	}
}
