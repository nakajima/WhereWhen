//
//  File.swift
//  
//
//  Created by Pat Nakajima on 6/4/24.
//

import Foundation
@preconcurrency import ServerData

@Model(table: "checkins") struct ServerCheckin {
	var id: Int?
	var uuid: String
	var latitude: Double
	var longitude: Double
	var savedAt: Date
	var accuracy: Double
	var arrivalDate: Date?
	var departureDate: Date?

	init(id: Int? = nil, uuid: String, latitude: Double, longitude: Double, savedAt: Date, accuracy: Double, arrivalDate: Date? = nil, departureDate: Date? = nil) {
		self.id = id
		self.uuid = uuid
		self.latitude = latitude
		self.longitude = longitude
		self.savedAt = savedAt
		self.accuracy = accuracy
		self.arrivalDate = arrivalDate
		self.departureDate = departureDate
	}
}
