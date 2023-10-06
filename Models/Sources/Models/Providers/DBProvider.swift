//
//  DBProvider.swift
//  LookLookSee2
//
//  Created by Pat Nakajima on 7/1/23.
//

import Blackbird
import pat_swift
import SwiftUI

public struct DBProvider<Content: View>: View {
	public enum Kind {
		case memory, name(String)
	}

	var content: () -> Content
	var db: Blackbird.Database

	public init(_ kind: DBProvider.Kind, content: @escaping () -> Content) {
		if case let .name(string) = kind {
			self.db = try! Blackbird.Database(
				path: URL.documentsDirectory.appendingPathComponent(string).path,
				options: [
					//					.debugPrintEveryQuery, .debugPrintQueryParameterValues
				]
			)
		} else {
			self.db = try! Blackbird.Database.inMemoryDatabase()
		}

		self.content = content
	}

	public var body: some View {
		content()
			.environment(\.blackbirdDatabase, db)
			.onAppear {
				Log.debug("DB: \(db.path ?? "in memory")")
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
