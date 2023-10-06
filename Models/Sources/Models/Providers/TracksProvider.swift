//
//  TracksProvider.swift
//
//
//  Created by Pat Nakajima on 10/5/23.
//

import Blackbird
import SwiftUI

struct TrackLoaderWrapper<Content: View>: View {
    var database: Database
    var apiClient: ApiClient
    var loader: TrackLoader
    var content: (TrackLoader) -> Content

    init(database: Database, apiClient: ApiClient, content: @escaping (TrackLoader) -> Content) {
        self.database = database
        self.apiClient = apiClient
        self.content = content
        loader = TrackLoader(database: database, client: apiClient)
    }

    var body: some View {
        content(loader)
    }
}

public struct TracksProvider<Content: View>: View {
    @Environment(\.apiClient) var client

    var content: (TrackLoader, [Track]) -> Content

    // Async-loading, auto-updating array of matching instances
    @BlackbirdLiveModels({ try await Track.read(from: $0, orderBy: .descending(\.$updatedAt)) }) var tracks

    @Environment(\.blackbirdDatabase) var db: Database?

    public init(content: @escaping (TrackLoader, [Track]) -> Content) {
        self.content = content
    }

    public var body: some View {
        if let db {
            TrackLoaderWrapper(database: db, apiClient: client) { loader in
                content(loader, tracks.results)
            }
        } else {
            Text("No database provided.")
        }
    }
}

#Preview {
    DBProvider(.memory) {
        ClientProvider {
            TracksProvider { _, _ in
                Text("Hi")
            }
        }
    }
}
