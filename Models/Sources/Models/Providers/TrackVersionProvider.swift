//
//  TrackVersionProvider.swift
//
//
//  Created by Pat Nakajima on 10/5/23.
//

import Blackbird
import SwiftUI

struct TrackVersionWrapper<Content: View>: View {
    var content: (TrackVersion) -> Content
    @BlackbirdLiveModel var version: TrackVersion?

    var body: some View {
        if let version {
            content(version)
        } else {
            EmptyView()
        }
    }
}

public struct TrackVersionProvider<Content: View>: View {
    @Environment(\.apiClient) var apiClient
    @Environment(\.blackbirdDatabase) var database

    var track: Track
    var content: (TrackVersion) -> Content

    @State var version: TrackVersion?
    var versionUpdater = TrackVersion.InstanceUpdater()

    public init(track: Track, content: @escaping (TrackVersion) -> Content) {
        self.track = track
        self.content = content
    }

    public var body: some View {
        if let database {
            view(database: database)
        } else {
            Text("No database")
        }
    }

    func view(database: Database) -> some View {
        versionUpdater.bind(from: database, to: $version, id: track.currentVersionID)

        return Group {
            if let version {
                TrackVersionWrapper(content: content, version: version.liveModel)
            } else {
                Text("No version.")
            }
        }
    }
}

#Preview {
    DBProvider(.memory) {
        ClientProvider {
            TrackVersionProvider(track: Track.list[0]) { _ in
                Text("Hi")
            }
        }
    }
}
