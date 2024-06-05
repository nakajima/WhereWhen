//
//  Checkin.swift
//  Fourskie
//
//  Created by Pat Nakajima on 6/4/24.
//

import CoreLocation
import SwiftData

@Model final class Checkin {
	struct Coordinate: Codable {
		let latitude: Double
		let longitude: Double
	}

	var coordinate: Coordinate
	var savedAt: Date
	var accuracy: Double

	var arrivalDate: Date?
	var departureDate: Date?

	init(visit: CLVisit) {
		self.coordinate = .init(
			latitude: visit.coordinate.latitude,
			longitude: visit.coordinate.longitude
		)

		self.savedAt = Date()
		self.arrivalDate = visit.arrivalDate == .distantPast ? nil : visit.arrivalDate
		self.departureDate = visit.departureDate == .distantPast ? nil : visit.departureDate
		self.accuracy = visit.horizontalAccuracy
	}
}
