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

struct PlayerProvider<Content: View>: View {
	@State private var pathManager: PathManager = .init()
	@StateObject var session = PlayerSession()
	@Environment(\.dbQueue) var dbQueue

	var content: () -> Content

	var body: some View {
		content()
			.scrollDismissesKeyboard(.interactively)
			.environmentObject(session)
			.onAppear {
				session.playlist = AllTracksPlaylist(dbQueue: dbQueue)
			}
			.onPreferenceChange(PathManagerPreferenceKey.self, perform: { value in
				self.pathManager = value
			})
	}
}

#Preview {
	ContentView()
}
