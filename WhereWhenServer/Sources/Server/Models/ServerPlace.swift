//
//  ServerPlace.swift
//
//
//  Created by Pat Nakajima on 6/5/24.
//

import Foundation
import LibWhereWhen
import ServerData

@Model(table: "places") struct ServerPlace: Codable, Sendable {
	@Column(.primaryKey(autoIncrement: true)) var id: Int?

	@Column(.unique) var uuid: String

	var coordinateID: String

	// When was this place added
	var addedAt: Date
	var attribution: String?

	// The lat/lng of the place. Stored as fields instead of Coordinate
	// so we can query easier
	var latitude: Double
	var longitude: Double

	// About
	var name: String
	var phoneNumber: String?
	var url: URL?
	var category: PlaceCategory?

	// Address
	var thoroughfare: String?
	var subThoroughfare: String?
	var locality: String?
	var subLocality: String?
	var administrativeArea: String?
	var subAdministrativeArea: String?
	var postalCode: String?

	var isIgnored: Bool = false
}
