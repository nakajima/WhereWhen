//
//  LocalCheckin.swift
//  Fourskie
//
//  Created by Pat Nakajima on 6/4/24.
//

import CoreLocation
import LibFourskie
import SwiftData

@Model final class LocalCheckin {
	@Attribute(.unique) var uuid = UUID().uuidString

	@Transient var source: CheckinSource = .manual
	var coordinate: Coordinate
	var savedAt: Date
	var accuracy: Double

	var arrivalDate: Date?
	var departureDate: Date?

	var place: LocalPlace?

	init(visit: CLVisit) {
		self.coordinate = .init(
			latitude: visit.coordinate.latitude,
			longitude: visit.coordinate.longitude
		)

		self.source = .automatic
		self.savedAt = Date()
		self.arrivalDate = visit.arrivalDate == .distantPast ? nil : visit.arrivalDate
		self.departureDate = visit.departureDate == .distantPast ? nil : visit.departureDate
		self.accuracy = visit.horizontalAccuracy
	}

	init(
		source: CheckinSource,
		uuid: String,
		coordinate: Coordinate,
		savedAt: Date,
		accuracy: Double,
		arrivalDate: Date?,
		departureDate: Date?,
		place: LocalPlace?
	) {
		self.source = source
		self.uuid = uuid
		self.coordinate = coordinate
		self.savedAt = savedAt
		self.accuracy = accuracy
		self.arrivalDate = arrivalDate
		self.departureDate = departureDate
		self.place = place
	}
}
