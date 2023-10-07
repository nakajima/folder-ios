// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetTrackVersionDownloadURLQuery: GraphQLQuery {
  public static let operationName: String = "GetTrackVersionDownloadURL"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query GetTrackVersionDownloadURL($dbid: String!) { viewer { __typename trackVersionDownloadURL(dbid: $dbid) } }"#
    ))

  public var dbid: String

  public init(dbid: String) {
    self.dbid = dbid
  }

  public var __variables: Variables? { ["dbid": dbid] }

  public struct Data: API.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

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
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { API.Objects.Viewer }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("trackVersionDownloadURL", String?.self, arguments: ["dbid": .variable("dbid")]),
      ] }

      /// Get a fresh track version download URL
      public var trackVersionDownloadURL: String? { __data["trackVersionDownloadURL"] }
    }
  }
}
