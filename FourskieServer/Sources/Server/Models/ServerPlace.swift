//
//  ServerPlace.swift
//
//
//  Created by Pat Nakajima on 6/5/24.
//

import Foundation
import LibFourskie
import ServerData

@Model(table: "places") struct ServerPlace: Codable, Sendable {
	@Column(.primaryKey(autoIncrement: true)) var id: Int?

	var uuid: String

	var coordinateID: String

	// When was this place added
	let addedAt: Date

	// The lat/lng of the place. Stored as fields instead of Coordinate
	// so we can query easier
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
}
