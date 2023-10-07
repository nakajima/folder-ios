//
//  NavigationProvider.swift
//  folder-ios
//
//  Created by Pat Nakajima on 10/6/23.
//

import Models
import SwiftUI

struct PathManagerPreferenceKey: PreferenceKey {
	static var defaultValue = PathManager()

	static func reduce(value: inout PathManager, nextValue: () -> PathManager) {
		value = nextValue()
	}
}

enum Route: Hashable {
	case home, track(Track), folder(Folder)
}

class PathManager: ObservableObject, Identifiable, Equatable {
	static func == (lhs: PathManager, rhs: PathManager) -> Bool {
		lhs.id == rhs.id
	}

	var id = UUID()

	@Published var path: [Route] = []

	func append(_ route: Route) {
		if path.last == route {
			return
		}

		withAnimation {
			path.append(route)
		}
	}
}

struct NavigationProvider<Content: View>: View {
	@StateObject var pathManager = PathManager()
	@EnvironmentObject var session: PlayerSession

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
				.preference(key: PathManagerPreferenceKey.self, value: pathManager)
		}
		.environmentObject(pathManager)
		.safeAreaInset(edge: .bottom) {
			PlayerView(playerSession: session)
				.environmentObject(session)
				.environmentObject(pathManager)
				.transition(.move(edge: .bottom))
		}
	}
}

#Preview {
	NavigationProvider {
		Text("Hi")
	}
}
