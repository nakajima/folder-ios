//
//  TrackListView.swift
//  folder-ios
//
//  Created by Pat Nakajima on 10/3/23.
//

import Models
import SwiftUI

struct TrackListView: View {
    @EnvironmentObject var playerSession: PlayerSession
    @Environment(\.blackbirdDatabase) var database

    var body: some View {
        TracksProvider { loader, tracks in
            List {
                ForEach(tracks) { track in
                    NavigationLink(
                        destination: TrackShowView(track: track)
                            .task(priority: .userInitiated) {
                                if playerSession.nowPlaying != nil {
                                    return
                                }

                                let currentVersion = try! await TrackVersion.read(from: database!, id: track.currentVersionID)!

                                await playerSession.play(version: currentVersion, from: database!)
                            }
                    ) {
                        TrackListCellView(track: track)
                    }
                }
                Spacer()
                    .frame(height: 64)
                    .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Home")
            .task {
                await loader.load()

                Task.detached {
                    await loader.downloadLatestVersions()
                }
            }
            .refreshable {
                await loader.load()

                Task.detached {
                    await loader.downloadLatestVersions()
                }
            }
        }
    }
}

#Preview {
    DBProvider(.memory) {
        ClientProvider {
            PlayerProvider {
                ContentView()
            }
        }
    }
}
