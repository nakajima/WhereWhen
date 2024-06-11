//
//  CheckinMaker.swift
//  WhereWhen
//
//  Created by Pat Nakajima on 6/8/24.
//

import Database
import Foundation
@preconcurrency import GRDB
import LibWhereWhen

struct CheckinCreator {
	let checkin: Checkin
	let database: DatabaseContainer

	func create(place: Place?) async throws {
		// TODO: use sql query instead of filtering in swift
		let ignoredPlaces = try await Place.where(Column("isIgnored") == true, in: database)

		for place in ignoredPlaces {
			if place.coordinate.distance(to: checkin.coordinate) < 10 {
				return
			}
		}

		var checkin = checkin
		checkin.place = place
		try await checkin.save(to: database)
	}
}
