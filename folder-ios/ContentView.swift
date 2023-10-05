//
//  ContentView.swift
//  folder-ios
//
//  Created by Pat Nakajima on 10/3/23.
//

import SwiftUI

struct ContentView: View {
	var body: some View {
		PlayerProvider {
			NavigationStack {
				TrackListView()
			}
		}
	}
}

#Preview {
    ContentView()
}
