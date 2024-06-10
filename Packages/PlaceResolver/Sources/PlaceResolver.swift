//
//  PlaceResolver.swift
//  WhereWhen
//
//  Created by Pat Nakajima on 6/9/24.
//

import Foundation
import LibWhereWhen

struct PlaceResolver {
	protocol Resolver {
		func place() async throws -> Place?
		init(database: Database, coordinate: Coordinate)
	}

	let database: Database
	let coordinate: Coordinate

	let resolvers: [any Resolver.Type] = [
		LocalDatabase.self,
		MapKit.self,
		Overpass.self,
		Nominatim.self,
	]

	func resolve() -> Place? {
		nil
	}
}
