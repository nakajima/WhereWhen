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
import PlaceResolver

private let logger = DiskLogger(label: "CheckinCreator", location: URL.documentsDirectory.appending(path: "wherewhen.log"))

// Maybe saves a checkin to the DB.
@MainActor struct CheckinCreator {
	let checkin: Checkin
	let database: DatabaseContainer

	func create(place: Place?) async throws {
		// TODO: use sql query instead of filtering in swift
		let ignoredPlaces = try await Place.where(Column("isIgnored") == true, in: database)

		for place in ignoredPlaces {
			if place.coordinate.distance(to: checkin.coordinate) < 10 {
				logger.info("Too close to ignored place: \(place.name), skipping checkin")
				return
			}
		}

		let query = Checkin.withPlace.order(Column("savedAt").desc)
		let lastCheckin = try await database.read { db in
			try query.fetchOne(db)
		}

		let place = if let place {
			place
		} else {
			await PlaceResolver(
				database: database,
				coordinate: checkin.coordinate
			).bestGuessPlace()
		}

		// Try to avoid checking in at the same place in a row
		if let lastCheckin,
		   let lastPlace = lastCheckin.place,
		   let place,
		   lastPlace.same(as: place),
		   // if it's older than 24 hours, don't worry about it
		   lastCheckin.savedAt > Date().addingTimeInterval(-60 * 60 * 24)
		{
			logger.info("Last checkin was at same place: \(place), lastPlace: \(lastPlace)")
			return
		}

		var checkin = checkin
		checkin.place = place
		try await checkin.save(to: database)
	}
}
