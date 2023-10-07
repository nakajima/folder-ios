// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class TrackLoaderQuery: GraphQLQuery {
	public static let operationName: String = "TrackLoaderQuery"
	public static let operationDocument: ApolloAPI.OperationDocument = .init(
		definition: .init(
			#"query TrackLoaderQuery { viewer { __typename feedTracks { __typename edges { __typename node { __typename nodeID: id id: dbid name updatedAt shareUrl folders { __typename nodes { __typename id: dbid nodeID: id name orderedTrackIDs } } versions { __typename edges { __typename node { __typename ...TrackVersionFragment } } } } } } } }"#,
			fragments: [TrackVersionFragment.self]
		))

	public init() {}

	public struct Data: API.SelectionSet {
		public let __data: DataDict
		public init(_dataDict: DataDict) { self.__data = _dataDict }

		public static var __parentType: ApolloAPI.ParentType { API.Objects.Query }
		public static var __selections: [ApolloAPI.Selection] { [
			.field("viewer", Viewer?.self),
		] }

		/// The viewer
		public var viewer: Viewer? { __data["viewer"] }

		/// Viewer
		///
		/// Parent Type: `Viewer`
		public struct Viewer: API.SelectionSet {
			public let __data: DataDict
			public init(_dataDict: DataDict) { self.__data = _dataDict }

			public static var __parentType: ApolloAPI.ParentType { API.Objects.Viewer }
			public static var __selections: [ApolloAPI.Selection] { [
				.field("__typename", String.self),
				.field("feedTracks", FeedTracks?.self),
			] }

			/// The tracks for a user
			public var feedTracks: FeedTracks? { __data["feedTracks"] }

			/// Viewer.FeedTracks
			///
			/// Parent Type: `TrackConnection`
			public struct FeedTracks: API.SelectionSet {
				public let __data: DataDict
				public init(_dataDict: DataDict) { self.__data = _dataDict }

				public static var __parentType: ApolloAPI.ParentType { API.Objects.TrackConnection }
				public static var __selections: [ApolloAPI.Selection] { [
					.field("__typename", String.self),
					.field("edges", [Edge?]?.self),
				] }

				/// A list of edges.
				public var edges: [Edge?]? { __data["edges"] }

				/// Viewer.FeedTracks.Edge
				///
				/// Parent Type: `TrackEdge`
				public struct Edge: API.SelectionSet {
					public let __data: DataDict
					public init(_dataDict: DataDict) { self.__data = _dataDict }

					public static var __parentType: ApolloAPI.ParentType { API.Objects.TrackEdge }
					public static var __selections: [ApolloAPI.Selection] { [
						.field("__typename", String.self),
						.field("node", Node?.self),
					] }

					/// The item at the end of the edge.
					public var node: Node? { __data["node"] }

					/// Viewer.FeedTracks.Edge.Node
					///
					/// Parent Type: `Track`
					public struct Node: API.SelectionSet {
						public let __data: DataDict
						public init(_dataDict: DataDict) { self.__data = _dataDict }

						public static var __parentType: ApolloAPI.ParentType { API.Objects.Track }
						public static var __selections: [ApolloAPI.Selection] { [
							.field("__typename", String.self),
							.field("id", alias: "nodeID", API.ID.self),
							.field("dbid", alias: "id", API.ID.self),
							.field("name", String.self),
							.field("updatedAt", API.DateTime.self),
							.field("shareUrl", String.self),
							.field("folders", Folders.self),
							.field("versions", Versions.self),
						] }

						public var nodeID: API.ID { __data["nodeID"] }
						public var id: API.ID { __data["id"] }
						public var name: String { __data["name"] }
						public var updatedAt: API.DateTime { __data["updatedAt"] }
						public var shareUrl: String { __data["shareUrl"] }
						public var folders: Folders { __data["folders"] }
						public var versions: Versions { __data["versions"] }

						/// Viewer.FeedTracks.Edge.Node.Folders
						///
						/// Parent Type: `FolderConnection`
						public struct Folders: API.SelectionSet {
							public let __data: DataDict
							public init(_dataDict: DataDict) { self.__data = _dataDict }

							public static var __parentType: ApolloAPI.ParentType { API.Objects.FolderConnection }
							public static var __selections: [ApolloAPI.Selection] { [
								.field("__typename", String.self),
								.field("nodes", [Node?]?.self),
							] }

							/// A list of nodes.
							public var nodes: [Node?]? { __data["nodes"] }

							/// Viewer.FeedTracks.Edge.Node.Folders.Node
							///
							/// Parent Type: `Folder`
							public struct Node: API.SelectionSet {
								public let __data: DataDict
								public init(_dataDict: DataDict) { self.__data = _dataDict }

								public static var __parentType: ApolloAPI.ParentType { API.Objects.Folder }
								public static var __selections: [ApolloAPI.Selection] { [
									.field("__typename", String.self),
									.field("dbid", alias: "id", API.ID.self),
									.field("id", alias: "nodeID", API.ID.self),
									.field("name", String.self),
									.field("orderedTrackIDs", [API.ID].self),
								] }

								public var id: API.ID { __data["id"] }
								public var nodeID: API.ID { __data["nodeID"] }
								public var name: String { __data["name"] }
								public var orderedTrackIDs: [API.ID] { __data["orderedTrackIDs"] }
							}
						}

						/// Viewer.FeedTracks.Edge.Node.Versions
						///
						/// Parent Type: `TrackVersionConnection`
						public struct Versions: API.SelectionSet {
							public let __data: DataDict
							public init(_dataDict: DataDict) { self.__data = _dataDict }

							public static var __parentType: ApolloAPI.ParentType { API.Objects.TrackVersionConnection }
							public static var __selections: [ApolloAPI.Selection] { [
								.field("__typename", String.self),
								.field("edges", [Edge?]?.self),
							] }

							/// A list of edges.
							public var edges: [Edge?]? { __data["edges"] }

							/// Viewer.FeedTracks.Edge.Node.Versions.Edge
							///
							/// Parent Type: `TrackVersionEdge`
							public struct Edge: API.SelectionSet {
								public let __data: DataDict
								public init(_dataDict: DataDict) { self.__data = _dataDict }

								public static var __parentType: ApolloAPI.ParentType { API.Objects.TrackVersionEdge }
								public static var __selections: [ApolloAPI.Selection] { [
									.field("__typename", String.self),
									.field("node", Node?.self),
								] }

								/// The item at the end of the edge.
								public var node: Node? { __data["node"] }

								/// Viewer.FeedTracks.Edge.Node.Versions.Edge.Node
								///
								/// Parent Type: `TrackVersion`
								public struct Node: API.SelectionSet {
									public let __data: DataDict
									public init(_dataDict: DataDict) { self.__data = _dataDict }

									public static var __parentType: ApolloAPI.ParentType { API.Objects.TrackVersion }
									public static var __selections: [ApolloAPI.Selection] { [
										.field("__typename", String.self),
										.fragment(TrackVersionFragment.self),
									] }

									public var id: API.ID { __data["id"] }
									public var node_id: API.ID { __data["node_id"] }
									public var duration: Int? { __data["duration"] }
									public var number: Int { __data["number"] }
									public var uuid: String { __data["uuid"] }
									public var isCurrent: Bool { __data["isCurrent"] }

									public struct Fragments: FragmentContainer {
										public let __data: DataDict
										public init(_dataDict: DataDict) { self.__data = _dataDict }

										public var trackVersionFragment: TrackVersionFragment { _toFragment() }
									}
								}
							}
						}
					}
				}
			}
		}
	}
}
