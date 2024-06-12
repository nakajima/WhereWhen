//
//  PlaceResolver.swift
//  WhereWhen
//
//  Created by Pat Nakajima on 6/9/24.
//

import Database
import Foundation
import LibWhereWhen

public struct PlaceResolver: Sendable {
	public struct Suggestion: Sendable, Identifiable {
		public var id: String { "\(source)-\(place.id)" }
		public let source: String
		public let place: Place
		public let confidence: Double
	}

	public protocol Resolver {
		func suggestion() async throws -> Suggestion?
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

	public func suggestions() async -> [Suggestion] {
		await withTaskGroup(of: Suggestion?.self) { group in
			for resolver in resolvers {
				group.addTask {
					do {
						if let suggestion = try await resolver.init(
							database: database,
							coordinate: coordinate
						).suggestion() {
							return suggestion
						}
					} catch {
						print("Error resolving: \(error)")
					}

					return nil
				}
			}

			var result: [Suggestion] = []

			for await suggestion in group.compactMap({ $0 }) {
				result.append(suggestion)
			}

			return result
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
				print("Error resolving: \(error)")
			}
		}

		return nil
	}
}
