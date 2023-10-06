//
//  Client.swift
//  Folder Desktop
//
//  Created by Pat Nakajima on 6/23/23.
//

import Apollo
import ApolloAPI
import Foundation
import KeychainAccess

public struct ApiClient {
	var token: String
	var apolloClient: ApolloClient

	static let keychain = Keychain(service: "fm.folder.Folder-Desktop")

	enum Environment: String {
		case dev = "https://folderfm.ngrok.io/graphql",
				 production = "https://folder.fm/graphql"
	}

	enum Error: Swift.Error {
		case queryError(String), mutationError(String)
	}

	static var environment: Environment {
		if let string = UserDefaults.standard.string(forKey: "env"), let env = Environment(rawValue: string) {
			return env
		}

		return .production
	}

	static func set(environment: Environment) {
		UserDefaults.standard.setValue(environment.rawValue, forKey: "env")
	}

	init(token: String) {
		self.token = token
		let url = URL(string: ApiClient.environment.rawValue)!

		let store = ApolloStore(cache: InMemoryNormalizedCache())
		let provider = DefaultInterceptorProvider(store: store)

		var headers: [String: String] = [:]

		if token != "" {
			headers["Authentication"] = "Bearer 4hQnHdeAjxwatp3wyD8gMEhe"
		}

		let transport = RequestChainNetworkTransport(interceptorProvider: provider, endpointURL: url, additionalHeaders: headers)

		self.apolloClient = ApolloClient(networkTransport: transport, store: store)
	}

	func fetch<Query: GraphQLQuery>(_ query: Query) async throws -> Query.Data {
		try await withCheckedThrowingContinuation { continuation in
			apolloClient.fetch(query: query) { result in
				switch result {
				case let .success(graphQLResult):
					if let data = graphQLResult.data {
						continuation.resume(returning: data)
					} else {
						continuation.resume(throwing: Error.queryError("\(String(describing: graphQLResult.errors))"))
					}
				case let .failure(error):
					continuation.resume(throwing: error)
				}
			}
		}
	}

	func perform<Mutation: GraphQLMutation>(_ mutation: Mutation) async throws -> Mutation.Data {
		try await withCheckedThrowingContinuation { continuation in
			apolloClient.perform(mutation: mutation) { result in
				switch result {
				case let .success(graphQLResult):
					if let data = graphQLResult.data {
						continuation.resume(returning: data)
						return
					} else {
						continuation.resume(throwing: Error.mutationError("\(String(describing: graphQLResult.errors))"))
						return
					}
				case let .failure(error):
					continuation.resume(throwing: error)
					return
				}
			}
		}
	}
}
