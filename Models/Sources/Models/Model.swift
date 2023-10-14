//
//  Model.swift
//  
//
//  Created by Pat Nakajima on 10/13/23.
//

import Foundation
import GRDB
import GRDBQuery
import Combine

protocol Model: Identifiable, Codable, Equatable, Hashable, FetchableRecord, PersistableRecord {
	static func createTable(in: Database) throws
}

struct ModelQuery<T: Model>: Queryable {
	static var defaultValue: [T] { [] }

	func publisher(in dbQueue: DatabaseQueue) -> AnyPublisher<[T], Error> {
		ValueObservation
			.tracking { db in
				return try T.fetchAll(db)
			}
		// The `.immediate` scheduling feeds the view right on subscription,
		// and avoids an initial rendering with an empty list:
		.publisher(in: dbQueue, scheduling: .immediate)
		.eraseToAnyPublisher()
	}
}

extension Model {
	static func find(in queue: DatabaseQueue, key: some DatabaseValueConvertible) async throws -> Self? {
		try await queue.read { db in
			try Self.filter(Column("id") == key).fetchOne(db)
		}
	}

	func save(to queue: DatabaseQueue) async throws {
		try await queue.write { db in
			try self.save(db)
		}
	}
}
