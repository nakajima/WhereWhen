//
//  PlaceResolver.swift
//  WhereWhen
//
//  Created by Pat Nakajima on 6/9/24.
//

import Database
import Foundation
import LibWhereWhen

public struct PlaceResolver {
	public struct Suggestion {
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

	public func resolve() async throws -> Place? {
		for resolver in resolvers {
			if let suggestion = try await resolver.init(
				database: database,
				coordinate: coordinate
			).suggestion() {
				let place = suggestion.place
				try await place.save(to: database)
				return place
			}
		}

		return nil
	}
}
