//
//  CheckinMaker.swift
//  Fourskie
//
//  Created by Pat Nakajima on 6/8/24.
//

import Foundation
@preconcurrency import GRDB
import LibFourskie

struct CheckinCreator {
	let checkin: Checkin
	let database: Database

	func create(place: Place?) async throws {
		// TODO: use spatialite query instead of filtering in swift
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
