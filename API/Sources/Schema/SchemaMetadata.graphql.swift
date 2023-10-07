// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public typealias ID = String

public protocol SelectionSet: ApolloAPI.SelectionSet & ApolloAPI.RootSelectionSet
	where Schema == API.SchemaMetadata {}

public protocol InlineFragment: ApolloAPI.SelectionSet & ApolloAPI.InlineFragment
	where Schema == API.SchemaMetadata {}

public protocol MutableSelectionSet: ApolloAPI.MutableRootSelectionSet
	where Schema == API.SchemaMetadata {}

public protocol MutableInlineFragment: ApolloAPI.MutableSelectionSet & ApolloAPI.InlineFragment
	where Schema == API.SchemaMetadata {}

public enum SchemaMetadata: ApolloAPI.SchemaMetadata {
	public static let configuration: ApolloAPI.SchemaConfiguration.Type = SchemaConfiguration.self

	public static func objectType(forTypename typename: String) -> Object? {
		switch typename {
		case "Query": return API.Objects.Query
		case "Viewer": return API.Objects.Viewer
		case "TrackConnection": return API.Objects.TrackConnection
		case "TrackEdge": return API.Objects.TrackEdge
		case "Track": return API.Objects.Track
		case "Folder": return API.Objects.Folder
		case "TrackVersion": return API.Objects.TrackVersion
		case "Note": return API.Objects.Note
		case "Project": return API.Objects.Project
		case "ProjectUpload": return API.Objects.ProjectUpload
		case "ShareLink": return API.Objects.ShareLink
		case "TrackComment": return API.Objects.TrackComment
		case "User": return API.Objects.User
		case "FolderConnection": return API.Objects.FolderConnection
		case "TrackVersionConnection": return API.Objects.TrackVersionConnection
		case "TrackVersionEdge": return API.Objects.TrackVersionEdge
		default: return nil
		}
	}
}

public enum Objects {}
public enum Interfaces {}
public enum Unions {}
