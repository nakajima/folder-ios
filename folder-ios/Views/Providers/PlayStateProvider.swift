//
//  PlayStateProvider.swift
//  folder-ios
//
//  Created by Pat Nakajima on 10/5/23.
//

import SwiftUI
import Models

struct PlayStateProvider<Content: View>: View {
	@EnvironmentObject var playerSession: PlayerSession

	var version: TrackVersion
	var content: (Bool) -> Content

	var body: some View {
		content(false)
	}
}

