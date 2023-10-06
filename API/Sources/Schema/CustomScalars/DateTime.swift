// @generated
// This file was automatically generated and can be edited to
// implement advanced custom scalar functionality.
//
// Any changes to this file will not be overwritten by future
// code generation execution.

import ApolloAPI
import Foundation

public typealias DateTime = Date

private let iso8601DateFormatter = ISO8601DateFormatter()

extension DateTime: JSONDecodable, JSONEncodable, CustomScalarType {
	public var _jsonValue: ApolloAPI.JSONValue {
		iso8601DateFormatter.string(from: self)
	}

	public init(_jsonValue value: JSONValue) throws {
		guard let string = value as? String else {
			throw JSONDecodingError.couldNotConvert(value: value, to: String.self)
		}

		guard let date = iso8601DateFormatter.date(from: string) else {
			throw JSONDecodingError.couldNotConvert(value: value, to: Date.self)
		}

		self = date
	}
}
