//
//  TimeInterval.swift
//  folder-ios
//
//  Created by Pat Nakajima on 10/3/23.
//

import Foundation

extension TimeInterval {
	var formatDuration: String {
		let s = Int(self) % 60
		let m = Int(self) / 60
		return String(format: "%0d:%02d", m, s)
	}
}
