//
//  PlayerProvider.swift
//  folder-ios
//
//  Created by Pat Nakajima on 10/4/23.
//

import AVFAudio
import Models
import pat_swift
import SwiftUI

struct NowPlaying: Identifiable, Equatable {
    var id: String {
        "\(track.id)-\(version.id)"
    }

    var track: Track
    var version: TrackVersion
    var isPlaying = false
    var currentTime: TimeInterval = 0
}

struct PlayButton: View {
    @EnvironmentObject var playerSession: PlayerSession
    @Environment(\.blackbirdDatabase) var database

    var track: Track
    @State var version: TrackVersion?

    var playIcon = "play.circle"
    var pauseIcon = "pause.circle"
    var size: CGFloat = 24

    var body: some View {
        if let version {
            Button(action: {
                playerSession.toggle(track: track, version: version)
            }) {
                Image(systemName: isPlaying ? pauseIcon : playIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size, height: size)
                    .foregroundColor(.primary)
            }
        } else {
            ProgressView()
                .task {
                    guard let database,
                          let version = try? await TrackVersion.read(
                              from: database,
                              id: track.currentVersionID
                          ) else { return }

                    await MainActor.run {
                        self.version = version
                    }
                }
        }
    }

    var isPlaying: Bool {
        guard let nowPlaying = playerSession.nowPlaying else {
            print("nowPlaying is nil")
            return false
        }

        if nowPlaying.track == track && nowPlaying.version == version {
            return nowPlaying.isPlaying
        } else {
            return false
        }
    }
}

actor AudioPlayerCore {
    var audioPlayer: AVAudioPlayer?

    var isPlaying: Bool {
        audioPlayer?.isPlaying ?? false
    }

    var currentTime: TimeInterval {
        audioPlayer?.currentTime ?? 0
    }

    func play(url: URL) {
        load(url: url)

        guard let audioPlayer else {
            return
        }

        audioPlayer.play()
    }

    func pause() {
        audioPlayer?.pause()
    }

    func load(url: URL) {
        if audioPlayer?.url == url {
            return
        }

        Log.catch("Error loading URL \(url)") {
            self.audioPlayer = try AVAudioPlayer(contentsOf: url)
            self.audioPlayer?.prepareToPlay()
        }
    }
}

class PlayerSession: ObservableObject {
    @Published var nowPlaying: NowPlaying?

    var audioPlayerCore = AudioPlayerCore()
    var timer: Timer?

    init() {
        Log.catch("Error setting up audio session") {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.allowBluetooth, .allowAirPlay])
            try AVAudioSession.sharedInstance().setActive(true)
        }

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            Task(priority: .medium) {
                await self.sync()
            }
        }
    }

    @objc func update() {
        Task(priority: .medium) {
            await self.sync()
        }
    }

    var isPlaying: Bool {
        nowPlaying?.isPlaying ?? false
    }

    func toggle(track: Track, version: TrackVersion) {
        Task(priority: .userInitiated) {
            if let nowPlaying {
                if nowPlaying.track != track || nowPlaying.version != version {
                    await play(track: track, version: version)
                    return
                }
            }

            if isPlaying {
                await pause()
            } else {
                await play(track: track, version: version)
            }
        }
    }

    func play(track: Track, version: TrackVersion) async {
        await audioPlayerCore.play(url: version.downloadURL)

        if let nowPlaying, nowPlaying.track == track, nowPlaying.version == version {
            print("it's all the same")
            return
        }

        await MainActor.run {
            withAnimation(.spring(duration: 0.4)) {
                nowPlaying = .init(track: track, version: version)
            }
        }

        await sync()
    }

    func play(version: TrackVersion, from db: Database) async {
        guard let track = try! await version.track(in: db) else {
            return
        }

        await play(track: track, version: version)
    }

    func pause() async {
        await audioPlayerCore.pause()
        await sync()
    }

    func sync() async {
        guard var newNowPlaying = nowPlaying else {
            return
        }

        newNowPlaying.isPlaying = await audioPlayerCore.isPlaying
        newNowPlaying.currentTime = await audioPlayerCore.currentTime

        let nowPlaying = newNowPlaying

        await MainActor.run {
            self.nowPlaying = nowPlaying
        }
    }
}

struct PlayerProvider<Content: View>: View {
    @StateObject var session = PlayerSession()

    var content: () -> Content

    var body: some View {
        content()
            .scrollDismissesKeyboard(.interactively)
            .safeAreaInset(edge: .bottom) {
                PlayerView()
                    .environmentObject(session)
                    .transition(.move(edge: .bottom))
            }
            .environmentObject(session)
    }
}

#Preview {
    ContentView()
}
