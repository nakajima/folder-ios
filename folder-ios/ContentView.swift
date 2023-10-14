//
//  ContentView.swift
//  folder-ios
//
//  Created by Pat Nakajima on 10/3/23.
//

import Models
import SwiftUI

struct ContentView: View {
	var body: some View {
		DBProvider(.name("folderfm.db")) {
			ClientProvider {
				PlayerProvider {
					NavigationProvider {
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
