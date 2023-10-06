//
//  ContentView.swift
//  folder-ios
//
//  Created by Pat Nakajima on 10/3/23.
//

import SwiftUI
import Models

struct ContentView: View {
	var body: some View {
		DBProvider(.name("Hi.db")) {
			ClientProvider {
				PlayerProvider {
					NavigationStack {
						TrackListView()
					}
				}
			}
		}
	}
}

#Preview {
    ContentView()
}
