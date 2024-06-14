//
//  PlaceResolverSuggestionSorter.swift
//
//
//  Created by Pat Nakajima on 6/13/24.
//

import Database
import GRDB
import LibWhereWhen

extension PlaceResolver.Suggestion {
	struct Sorter: Sendable {
		typealias Criteria = (
			Int, // Number of checkins matters most
			Double // Distance matters second most
		)

		let context: PlaceResolver.Context
		let suggestions: [PlaceResolver.Suggestion]
		let checkinCountsByPlaceID: [String: Int]

		init(context: PlaceResolver.Context, suggestions: [PlaceResolver.Suggestion]) {
			self.checkinCountsByPlaceID = Self.countsByPlaceID(in: context.database)
			self.context = context
			self.suggestions = suggestions
		}

		func sorted() throws -> [PlaceResolver.Suggestion] {
			return suggestions.sorted(by: {
				criteria($0) > criteria($1)
			})
		}

		func criteria(_ suggestion: PlaceResolver.Suggestion) -> Criteria {
			(
				checkinCountsByPlaceID[suggestion.place.uuid, default: 0],
				-context.coordinate.distance(to: suggestion.place.coordinate)
			)
		}

		static func countsByPlaceID(in database: DatabaseContainer) -> [String: Int] {
			do {
				let rows = try database.read { db in
					try Row.fetchAll(
						db,
						sql: "SELECT placeID, COUNT(1) AS count FROM checkin GROUP BY placeID"
					)
				}

				var result: [String: Int] = [:]
				for row in rows {
					let placeID: String = row["placeID"]
					let count: Int = row["count"]
					result[placeID] = count
				}

				return result
			} catch {
				return [:]
			}
		}
	}
}
