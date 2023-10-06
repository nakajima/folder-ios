//
//  Tag.swift
//
//
//  Created by Pat Nakajima on 10/6/23.
//

import Foundation
import Blackbird

public struct Tag: BlackbirdModel {
	public static let list: [String: String] = [
		"bass_guitar": "bass guitar",
		"guitar": "guitar",
		"electric_guitar": "electric guitar",
		"synthesizer": "synth",
		"singing" : "vocals",
		"drum_kit" : "drums",
		"keyboard_musical" : "synth",
		"piano": "piano"
	]

	public static var primaryKey: [BlackbirdColumnKeyPath] = [ \.$name, \.$trackID ]

	public static var indexes: [[BlackbirdColumnKeyPath]] = [
		[ \.$name ],
		[ \.$trackID ],
	]


	@BlackbirdColumn public var name: String
	@BlackbirdColumn public var trackID: Int
}
