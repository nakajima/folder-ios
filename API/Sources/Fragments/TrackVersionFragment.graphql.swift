// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct TrackVersionFragment: API.SelectionSet, Fragment {
	public static var fragmentDefinition: StaticString {
		#"fragment TrackVersionFragment on TrackVersion { __typename id: dbid node_id: id duration number uuid isCurrent }"#
	}

	public let __data: DataDict
	public init(_dataDict: DataDict) { self.__data = _dataDict }

	public static var __parentType: ApolloAPI.ParentType { API.Objects.TrackVersion }
	public static var __selections: [ApolloAPI.Selection] { [
		.field("__typename", String.self),
		.field("dbid", alias: "id", API.ID.self),
		.field("id", alias: "node_id", API.ID.self),
		.field("duration", Int?.self),
		.field("number", Int.self),
		.field("uuid", String.self),
		.field("isCurrent", Bool.self),
	] }

	public var id: API.ID { __data["id"] }
	public var node_id: API.ID { __data["node_id"] }
	public var duration: Int? { __data["duration"] }
	public var number: Int { __data["number"] }
	public var uuid: String { __data["uuid"] }
	public var isCurrent: Bool { __data["isCurrent"] }
}
