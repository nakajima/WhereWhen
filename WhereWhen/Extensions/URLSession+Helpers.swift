//
//  URLSession+Helpers.swift
//  WhereWhen
//
//  Created by Pat Nakajima on 6/6/24.
//

import Foundation

extension URLSession {
	func string(from url: URL) async throws -> String? {
		let data = try await URLSession.shared.data(from: url).0
		return String(data: data, encoding: .utf8)
	}
}
