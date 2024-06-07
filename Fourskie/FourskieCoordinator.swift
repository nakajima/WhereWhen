//
//  FourskieCoordinator.swift
//  Fourskie
//
//  Created by Pat Nakajima on 6/4/24.
//

import Foundation
import LibFourskie
import SwiftData
import SwiftUI

@MainActor final class FourskieCoordinator: ObservableObject {
	let container: ModelContainer

	@Published var isShowingManualCheckin = false
	@Published var errorMessage: String?
	@Published var navigation: [Route] = []

	init(container: ModelContainer) {
		self.container = container
	}

	func dismissError() {
		withAnimation {
			errorMessage = nil
		}
	}

	func updateCheckinPlace(checkin: Checkin, place: Place) {
		let context = container.mainContext

		let localCheckin = LocalCheckin.model(for: checkin, in: context)
		let localPlace = LocalPlace.model(for: place, in: context)
		context.insert(localPlace)

		localCheckin.place = localPlace

		do {
			try context.save()
			navigation = []
		} catch {
			errorMessage = error.localizedDescription
		}
	}

	func manualCheckIn(place: Place, from coordinate: Coordinate) {
		let context = container.mainContext
		let localPlace = LocalPlace.model(for: place, in: context)
		do {
			let checkin = LocalCheckin(
				source: .manual,
				uuid: UUID().uuidString,
				coordinate: coordinate,
				savedAt: Date(),
				accuracy: place.coordinate.distance(to: coordinate),
				arrivalDate: Date(),
				departureDate: nil,
				place: localPlace
			)

			container.mainContext.insert(checkin)

			try container.mainContext.save()
		} catch {
			errorMessage = error.localizedDescription
		}

		isShowingManualCheckin = false
	}
}
