//
//  Int+Formatting.swift
//  Fourskie
//
//  Created by Pat Nakajima on 6/6/24.
//

import Foundation

extension Int {
	func ordinalize(_ word: String, plural: String? = nil) -> String {
		let plural = plural ?? word + "s"

		switch self {
		case 0:
			return "no \(plural)"
		case 1:
			return "one \(word)"
		case 2 ... 10:
			let formatter = NumberFormatter()
			formatter.numberStyle = .spellOut
			let string = formatter.string(from: self as NSNumber) ?? "\(self)"
			return "\(string) \(plural)"
		default:
			return "\(self) \(plural)"
		}
	}
}
