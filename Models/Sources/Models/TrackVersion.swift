//
//  TrackVersion.swift
//
//
//  Created by Pat Nakajima on 10/5/23.
//

import Blackbird
import Foundation

public struct TrackVersion: BlackbirdModel, Equatable {
    @BlackbirdColumn public var id: Int
    @BlackbirdColumn public var nodeID: String
    @BlackbirdColumn public var duration: Int?
    @BlackbirdColumn public var number: Int
    @BlackbirdColumn public var trackID: Int
    @BlackbirdColumn public var uuid: String
    @BlackbirdColumn public var isCurrent: Bool
    @BlackbirdColumn public var status: VersionDownloader.State = .unknown

    public var downloadURL: URL {
        VersionDownloader.downloadsURL.appendingPathComponent("\(uuid).mp3")
    }

    public func track(in database: Database) async throws -> Track? {
        try await Track.read(from: database, id: trackID)
    }
}
