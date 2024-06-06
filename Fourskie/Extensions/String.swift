//
//  String.swift
//  Fourskie
//
//  Created by Pat Nakajima on 6/5/24.
//

import Foundation

extension String {
	// Like Rails' blank?
	var isBlank: Bool {
		trimmed == ""
	}

	// Like Rails' presence
	var presence: String? {
		isBlank ? nil : self
	}

	var trimmed: String {
		trimmingCharacters(in: .whitespacesAndNewlines)
	}
}
