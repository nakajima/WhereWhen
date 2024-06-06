//
//  Array.swift
//  Fourskie
//
//  Created by Pat Nakajima on 6/5/24.
//

import Foundation

extension Array {
	func first(_ limit: Int) -> Array {
		if limit < count {
			return Array(self[0..<limit])
		} else {
			return self
		}
	}
}
