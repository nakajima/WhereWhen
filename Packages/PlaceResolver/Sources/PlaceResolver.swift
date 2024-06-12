//
//  PlaceResolver.swift
//  WhereWhen
//
//  Created by Pat Nakajima on 6/9/24.
//

import Database
import Foundation
import LibWhereWhen

private let logger = DiskLogger(label: "PlaceResolver", location: URL.documentsDirectory.appending(path: "wherewhen.log"))

public struct PlaceResolver: Sendable {
	public struct Suggestion: Sendable, Identifiable {
		public var id: String { "\(source)-\(place.id)" }
		public let source: String
		public let place: Place
		public let confidence: Double
	}

	public protocol Resolver {
		var coordinate: Coordinate { get }
		func suggestions() async throws -> [Suggestion]
		init(database: DatabaseContainer, coordinate: Coordinate)
	}

	let database: DatabaseContainer
	let coordinate: Coordinate

	public init(database: DatabaseContainer, coordinate: Coordinate) {
		self.database = database
		self.coordinate = coordinate
	}

	let resolvers: [any Resolver.Type] = [
		LocalDatabase.self,
		MapKit.self,
		Overpass.self,
		Nominatim.self,
	]

	public func resolve() async -> Place? {
		await suggestion()?.place
	}

	public func suggestions(limit: Int? = nil) async -> [Suggestion] {
		await withTaskGroup(of: [Suggestion].self) { group in
			for resolver in resolvers {
				group.addTask {
					do {
						return try await resolver.init(
							database: database,
							coordinate: coordinate
						).suggestions()
					} catch {
						logger.error("Error resolving \(resolver): \(error)")
					}

					return []
				}
			}

			var result: [Suggestion] = []

			var knownByName: [String: Suggestion] = [:]
			for await suggestions in group {
				for suggestion in suggestions {
					// Prevent duplicate places returns by different sources from
					// showing up, favoring local results
					if let existing = knownByName[suggestion.place.name] {
						if existing.source == "Local" {
							knownByName[suggestion.place.name] = suggestion
						}

						continue
					}

					knownByName[suggestion.place.name] = suggestion
					result.append(suggestion)
				}
			}

			let sorted = result.sorted {
				$0.place.coordinate.distance(to: coordinate) <
					$1.place.coordinate.distance(to: coordinate)
			}

			if let limit, sorted.count > limit {
				return Array(sorted[0 ..< limit])
			} else {
				return sorted
			}
		}
	}

	public func suggestion() async -> Suggestion? {
		for resolver in resolvers {
			do {
				if let suggestion = try await resolver.init(
					database: database,
					coordinate: coordinate
				).suggestion() {
					return suggestion
				}
			} catch {
				logger.error("Error resolving: \(error)")
			}
		}

		return nil
	}
}

extension PlaceResolver.Resolver {
	func suggestion() async throws -> PlaceResolver.Suggestion? {
		try await suggestions().sorted {
			$0.place.coordinate.distance(to: coordinate) <
				$1.place.coordinate.distance(to: coordinate)
		}.first
	}
}
