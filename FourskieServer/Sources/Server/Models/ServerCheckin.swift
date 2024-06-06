//
//  File.swift
//  
//
//  Created by Pat Nakajima on 6/4/24.
//

import Foundation
import LibFourskie
@preconcurrency import ServerData

@Model(table: "checkins") struct ServerCheckin: Codable, Sendable {
	@Column(.primaryKey(autoIncrement: true)) var id: Int?

	var source: CheckinSource
	var uuid: String
	var latitude: Double
	var longitude: Double
	var savedAt: Date
	var accuracy: Double
	var arrivalDate: Date?
	var departureDate: Date?
	var place: ServerPlace?

	init(
		id: Int? = nil,
		source: CheckinSource,
		uuid: String, 
		latitude: Double,
		longitude: Double,
		savedAt: Date,
		accuracy: Double,
		arrivalDate: Date? = nil,
		departureDate: Date? = nil,
		place: ServerPlace? = nil
	) {
		self.id = id
		self.source = source
		self.uuid = uuid
		self.latitude = latitude
		self.longitude = longitude
		self.savedAt = savedAt
		self.accuracy = accuracy
		self.arrivalDate = arrivalDate
		self.departureDate = departureDate
		self.place = place
	}
}
