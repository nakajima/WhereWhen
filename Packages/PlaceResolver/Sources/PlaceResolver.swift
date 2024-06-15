//
//  PlaceResolver.swift
//  WhereWhen
//
//  Created by Pat Nakajima on 6/9/24.
//

import Database
import Foundation
import GRDB
import LibWhereWhen

private let logger = DiskLogger(label: "PlaceResolver", location: URL.documentsDirectory.appending(path: "wherewhen.log"))

public struct PlaceResolver: Sendable {
	public struct Context: Sendable {
		public let database: DatabaseContainer
		public let coordinate: Coordinate

		public init(database: DatabaseContainer, coordinate: Coordinate) {
			self.database = database
			self.coordinate = coordinate
		}
	}

	public protocol Resolver: Sendable {
		var context: Context { get }
		func suggestions() async throws -> [Suggestion]
		init(context: Context)
	}

	let context: Context

	public init(database: DatabaseContainer, coordinate: Coordinate) {
		self.context = Context(database: database, coordinate: coordinate)
	}

	let resolvers: [any Resolver.Type] = [
		LocalDatabase.self,
		MapKit.self,
		Overpass.self,
		Nominatim.self,
	]

	public func bestGuessPlace() async -> Place? {
		await suggestions(limit: 1).first?.place
	}

	public func suggestions(limit: Int? = nil) async -> [Suggestion] {
		await withTaskGroup(of: [Suggestion].self) { group in
			for resolver in resolvers {
				group.addTask {
					do {
						return try await resolver.init(
							context: context
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

			do {
				let sorted = try Suggestion.Sorter(context: context, suggestions: result).sorted()

				if let limit, sorted.count > limit {
					return Array(sorted[0 ..< limit])
				} else {
					return sorted
				}
			} catch {
				logger.error("Error sorting: \(error)")
				return result
			}
		}
	}
}
