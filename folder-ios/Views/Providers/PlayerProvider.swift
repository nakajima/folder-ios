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
	@StateObject var session = PlayerSession()
	@Environment(\.blackbirdDatabase) var database

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
			.onAppear {
				session.playlist = AllTracksPlaylist(database: database!)
			}
	}
}

#Preview {
	ContentView()
}
