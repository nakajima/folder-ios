//
//  NavigationProvider.swift
//  folder-ios
//
//  Created by Pat Nakajima on 10/6/23.
//

import SwiftUI
import Models

enum Route: Hashable {
	case home, track(Track), folder(Folder)
}

class PathManager: ObservableObject {
	@Published var path = NavigationPath()

	func append(_ route: Route) {
		withAnimation {
			path.append(route)
		}
	}
}

struct NavigationProvider<Content: View>: View {
	@StateObject var pathManager = PathManager()

	var content: () -> Content

	var body: some View {
		NavigationStack(path: $pathManager.path.animation(.default)) {
			content()
				.navigationDestination(for: Route.self) { route in
					switch route {
					case let .folder(folder):
						FolderView(folder: folder)
							.environmentObject(pathManager)
					case let .track(track):
						TrackShowView(track: track)
							.environmentObject(pathManager)
					case .home:
						TrackListView()
							.environmentObject(pathManager)
					}
				}
		}
		.environmentObject(pathManager)
	}
}

#Preview {
	NavigationProvider {
		Text("Hi")
	}
}
