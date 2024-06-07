//
//  Client.swift
//  Fourskie
//
//  Created by Pat Nakajima on 6/6/24.
//

import Foundation
import LibFourskie

struct FourskieClient {
	let serverURL: URL
	let logger = DiskLogger(label: "FourskieClient", location: URL.documentsDirectory.appending(path: "fourskie.log"))

	func lastSyncedAt() async -> Date {
		do {
			guard let string = try await URLSession.shared.string(from: serverURL.appending(path: "last-sync-at")) else {
				return .distantPast
			}

			return try JSONDecoder().decode(Date.self, from: Data(string.utf8))
		} catch {
			return .distantPast
		}
	}

	func isAvailable() async -> Bool {
		do {
			return try await URLSession.shared.string(from: serverURL) == "fourskie is up."
		} catch {
			logger.error("error checking server availability: \(error)")
			return false
		}
	}

	func upload(checkins: [Checkin]) async throws {
		let data = try JSONEncoder().encode(checkins)

		var request = URLRequest(url: serverURL.appending(path: "checkins"))
		request.httpMethod = "POST"

		_ = try await URLSession.shared.upload(for: request, from: data)
	}

	func download(since: Date) async throws -> [Checkin] {
		var request = URLRequest(url: serverURL.appending(path: "checkins"))
//		request.setValue(since.formatted(.iso8601), forHTTPHeaderField: "If-Modified-Since")

		let (data, response) = try await URLSession.shared.data(for: request)

		print(response)
		print(String(data: data, encoding: .utf8))

		return try JSONDecoder().decode([Checkin].self, from: data)
	}
}