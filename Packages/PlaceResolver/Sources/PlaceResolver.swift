//
//  PlaceResolver.swift
//  WhereWhen
//
//  Created by Pat Nakajima on 6/9/24.
//

import Foundation
import Database
import LibWhereWhen

public struct PlaceResolver {
	public protocol Resolver {
		func place() async throws -> Place?
		init(database: DatabaseContainer, coordinate: Coordinate)
	}

	let database: DatabaseContainer
	let coordinate: Coordinate

	let resolvers: [any Resolver.Type] = [
		LocalDatabase.self,
		MapKit.self,
		Overpass.self,
		Nominatim.self,
	]

	public func resolve() -> Place? {
		nil
	}
}
