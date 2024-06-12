//
//  PlaceFinder.swift
//  WhereWhen
//
//  Created by Pat Nakajima on 6/5/24.
//

import Database
import Foundation
import LibWhereWhen
import MapKit
import PlaceResolver

struct PlaceFinder {
	enum Error: Swift.Error {
		case noPlaceOrError
	}

	// We have a database so we can save found places
	let database: DatabaseContainer

	// Where is the user right now? This may differ from where they are searching
	let coordinate: Coordinate

	// A user entered string to search for
	let search: String

	init(database: DatabaseContainer, coordinate: Coordinate, search: String) {
		self.database = database
		self.coordinate = coordinate
		self.search = search
	}

	func results(in region: MKCoordinateRegion) async throws -> [Place] {
		let suggestions = await PlaceResolver(
			database: database,
			coordinate: .init(region.center)
		).suggestions()

		// Do some simple filtering if we have a search. It'd be nice to improve this
		// to be fuzzy at some point.
		if let search = search.presence {
			return suggestions.compactMap { suggestion in
				if suggestion.place.name.lowercased().contains(search.lowercased()) {
					return suggestion.place
				} else {
					return nil
				}
			}
		} else {
			return suggestions.map(\.place)
		}
	}
}
