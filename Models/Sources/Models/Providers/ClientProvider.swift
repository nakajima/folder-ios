//
//  ClientProvider.swift
//
//
//  Created by Pat Nakajima on 10/5/23.
//

import SwiftUI

private struct ApiClientEnvironmentKey: EnvironmentKey {
	static let defaultValue: ApiClient = ApiClient(token: "NOPE")
}


extension EnvironmentValues {
	var apiClient: ApiClient {
		get { self[ApiClientEnvironmentKey.self] }
		set { self[ApiClientEnvironmentKey.self] = newValue }
	}
}

public struct ClientProvider<Content: View>: View {
	@State var client: ApiClient?

	var content: () -> Content

	public init(content: @escaping () -> Content) {
		self.content = content
	}

	public var body: some View {
		if let client {
			content()
				.environment(\.apiClient, client)
		} else {
			ProgressView("No client…")
				.onAppear {
					self.client = ApiClient(token: "DEBUG")
				}
		}
	}
}
