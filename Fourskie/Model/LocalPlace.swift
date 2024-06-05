//
//  LocalPlace.swift
//  Fourskie
//
//  Created by Pat Nakajima on 6/5/24.
//

import Foundation
import LibFourskie
import SwiftData

@Model final class LocalPlace {
	@Attribute(.unique) var uuid = UUID().uuidString

	// Hack around the fact that SwiftData doesn't allow compound uniqueness:
	@Attribute(.unique) var coordinateID: String

	// When was this place added
	let addedAt: Date

	// The lat/lng of the place. Stored as fields instead of Coordinate
	// so we can query easier from SwiftData
	let latitude: Double
	let longitude: Double

	// About
	let name: String
	let phoneNumber: String?
	let url: URL?
	let category: PlaceCategory?

	// Address
	var thoroughfare: String?
	var subThoroughfare: String?
	var locality: String?
	var subLocality: String?
	var administrativeArea: String?
	var subAdministrativeArea: String?
	var postalCode: String?

	init(
		uuid: String,
		addedAt: Date,
		coordinate: Coordinate,
		name: String,
		phoneNumber: String? = nil,
		url: URL? = nil,
		category: PlaceCategory?,
		thoroughfare: String? = nil,
		subThoroughfare: String? = nil,
		locality: String? = nil,
		subLocality: String? = nil,
		administrativeArea: String? = nil,
		subAdministrativeArea: String? = nil,
		postalCode: String? = nil
	) {
		self.uuid = uuid
		self.coordinateID = coordinate.id

		self.addedAt = addedAt
		self.latitude = coordinate.latitude
		self.longitude = coordinate.longitude
		self.name = name
		self.phoneNumber = phoneNumber
		self.url = url
		self.category = category
		self.thoroughfare = thoroughfare
		self.subThoroughfare = subThoroughfare
		self.locality = locality
		self.subLocality = subLocality
		self.administrativeArea = administrativeArea
		self.subAdministrativeArea = subAdministrativeArea
		self.postalCode = postalCode
	}

	var coordinate: Coordinate {
		.init(latitude: latitude, longitude: longitude)
	}
}
