//
//  FourskieCoordinator.swift
//  Fourskie
//
//  Created by Pat Nakajima on 6/4/24.
//

import Foundation
import SwiftData
import LibFourskie

final class FourskieCoordinator: ObservableObject {
	let container: ModelContainer

	@Published var isShowingManualCheckin = false

	init(container: ModelContainer) {
		self.container = container
	}

	func manualCheckIn(place: Place, from coordinate: Coordinate) {
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
	}
}
