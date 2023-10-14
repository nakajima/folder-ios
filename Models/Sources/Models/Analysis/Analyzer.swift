//
//  Analyzer.swift
//
//
//  Created by Pat Nakajima on 10/6/23.
//

import CoreML
import GRDB
import Foundation
import SoundAnalysis

class Analyzer: NSObject, SNResultsObserving {
	var database: DatabaseQueue
	var track: Track
	var version: TrackVersion

	init(database: DatabaseQueue, track: Track, version: TrackVersion) {
		self.database = database
		self.track = track
		self.version = version
	}

	/// Notifies the observer when a request generates a prediction.
	func request(_: SNRequest, didProduce result: SNResult) {
		// Downcast the result to a classification result.
		guard let result = result as? SNClassificationResult else { return }

		for classification in result.classifications.sorted(by: { $0.confidence > $1.confidence })[0 ..< min(10, result.classifications.count - 1)] {
			if classification.confidence > 0.6, let tagName = Tag.list[classification.identifier] {
				Task(priority: .utility) {
					try await database.write { db in
						let tag = Tag(name: tagName, trackID: self.track.id)
						try tag.insert(db)
					}
				}
			}
		}
	}

	/// Notifies the observer when a request generates an error.
	func request(_: SNRequest, didFailWithError error: Error) {
		print("The analysis failed: \(error.localizedDescription)")
	}

	/// Notifies the observer when a request is complete.
	func requestDidComplete(_: SNRequest) {
		print("The request completed successfully!")
	}

	func start() async throws {
		let version1 = SNClassifierIdentifier.version1
		let request = try SNClassifySoundRequest(classifierIdentifier: version1)

		let analyzer = try SNAudioFileAnalyzer(url: version.downloadURL)
		try analyzer.add(request, withObserver: self)

		await analyzer.analyze()
	}
}
