//
//  FourskieCoordinator.swift
//  Fourskie
//
//  Created by Pat Nakajima on 6/4/24.
//

import Foundation
import LibFourskie
import SwiftUI

@MainActor final class FourskieCoordinator: ObservableObject {
	let database: Database

	@Published var isShowingManualCheckin = false
	@Published var errorMessage: String?
	@Published var navigation: [Route] = []

	let syncer: Syncer?

	init(database: Database) {
		self.database = database
		self.syncer = Syncer(
			database: database,
			client: .init(
				serverURL: URL(string: "http://localhost:4567")!
			)
		)

		sync()
	}

	func sync() {
		syncer?.sync()
	}

	func dismissError() {
		withAnimation {
			errorMessage = nil
		}
	}

	func updateCheckinPlace(checkin: Checkin, place: Place) {
		var checkin = checkin
		checkin.place = place

		do {
			try checkin.save(to: database)
			navigation = []
		} catch {
			errorMessage = error.localizedDescription
		}
	}

	func manualCheckIn(place: Place, from coordinate: Coordinate) {
		do {
			let checkin = Checkin(
				source: .manual,
				uuid: UUID().uuidString,
				coordinate: coordinate,
				savedAt: Date(),
				accuracy: place.coordinate.distance(to: coordinate),
				arrivalDate: Date(),
				departureDate: nil,
				place: place
			)

			try checkin.save(to: database)
		} catch {
			errorMessage = error.localizedDescription
		}

		isShowingManualCheckin = false
	}
}
