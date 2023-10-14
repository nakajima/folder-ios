//
//  DBProvider.swift
//  LookLookSee2
//
//  Created by Pat Nakajima on 7/1/23.
//

import GRDB
import pat_swift
import SwiftUI

public  struct DatabaseQueueKey: EnvironmentKey {
		/// The default dbQueue is an empty in-memory database
		public static var defaultValue: DatabaseQueue { try! DatabaseQueue() }
}

public extension EnvironmentValues {
		var dbQueue: DatabaseQueue {
				get { self[DatabaseQueueKey.self] }
				set { self[DatabaseQueueKey.self] = newValue }
		}
}

public struct DBProvider<Content: View>: View {
	public enum Kind {
		case memory, name(String)
	}

	var content: () -> Content
	var db: DatabaseQueue

	public init(_ kind: DBProvider.Kind, content: @escaping () -> Content) {
		if case let .name(string) = kind {
			self.db = try! DatabaseQueue(path: URL.documentsDirectory.appendingPathComponent(string).path)
		} else {
			self.db = try! DatabaseQueue()
		}

		self.content = content

		Migration.run(in: self.db)
	}

	public var body: some View {
		content()
			.environment(\.dbQueue, db)
			.onAppear {
				Log.debug("DB: \(db.path)")
			}
	}
}

struct DBProvider_Previews: PreviewProvider {
	static var previews: some View {
		DBProvider(.memory) {
			Text("hello")
		}
	}
}
