//
//  Track.swift
//  folder-ios
//
//  Created by Pat Nakajima on 10/3/23.
//

import Foundation

struct Track: Identifiable {
	static let list: [Track] = [
		.init(id: 1, name: "onmyown"),
		.init(id: 2, name: "termites 2023 11"),
		.init(id: 3, name: "timewitcher 3 with henry cavill"),
		.init(id: 4, name: "354"),
		.init(id: 5, name: "6am"),
		.init(id: 6, name: "street"),
		.init(id: 7, name: "fnl"),
		.init(id: 8, name: "saturdaywaa"),
		.init(id: 9, name: "play"),
		.init(id: 10, name: "play2"),
		.init(id: 11, name: "onmyown"),
		.init(id: 12, name: "termites 2023 11"),
		.init(id: 13, name: "timewitcher 3 with henry cavill"),
		.init(id: 14, name: "354"),
		.init(id: 15, name: "6am"),
		.init(id: 16, name: "street"),
		.init(id: 17, name: "fnl"),
		.init(id: 18, name: "saturdaywaa"),
		.init(id: 19, name: "play"),
		.init(id: 20, name: "play2"),
	]

	var id: Int
	var name: String
	var duration: TimeInterval = 324
}
