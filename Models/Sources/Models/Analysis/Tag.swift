//
//  Tag.swift
//
//
//  Created by Pat Nakajima on 10/6/23.
//

import Foundation

public struct Tag: Model {
	public static let list: [String: String] = [
		"bass_guitar": "bass guitar",
		"guitar": "guitar",
		"electric_guitar": "electric guitar",
		"synthesizer": "synth",
		"singing": "vocals",
		"drum_kit": "drums",
		"keyboard_musical": "synth",
		"piano": "piano",
	]

	public var id: Int?
	public var name: String
	public var trackID: Int
}
