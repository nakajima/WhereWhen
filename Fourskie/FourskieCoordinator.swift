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

	init(container: ModelContainer) {
		self.container = container
	}

	func dismissError() {
		withAnimation {
			errorMessage = nil
		}
	}

	func manualCheckIn(place: Place, from coordinate: Coordinate) {
		let context = container.mainContext
		do {
			let place = try context.first(where: #Predicate<LocalPlace> { $0.coordinateID == place.coordinate.id }) ?? LocalPlace(wrapped: place)

			container.mainContext.insert(place)

			let checkin = LocalCheckin(
				source: .manual,
				uuid: UUID().uuidString,
				coordinate: coordinate,
				savedAt: Date(),
				accuracy: place.coordinate.distance(to: coordinate),
				arrivalDate: Date(),
				departureDate: nil,
				place: place
			)

			container.mainContext.insert(checkin)

			try container.mainContext.save()
		} catch {
			errorMessage = error.localizedDescription
		}

		isShowingManualCheckin = false
	}
}
