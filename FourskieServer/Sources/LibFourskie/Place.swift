//
//  Place.swift
//
//
//  Created by Pat Nakajima on 6/5/24.
//

import Foundation

// Places. This is basically a wrapper around CLPlacemark
public struct Place: Codable, Identifiable, Sendable, Equatable {
	public var id: String { coordinate.id }

	public let uuid: String

	// When was this place added
	public let addedAt: Date

	// The lat/lng of the place
	public let coordinate: Coordinate

	public let category: PlaceCategory?

	// The name of the place.
	public let name: String

	// The phone number of the place
	public let phoneNumber: String?

	// The website
	public let url: URL?

	// The street address associated with the place.
	public let thoroughfare: String?

	// Additional street-level information for the place.
	public let subThoroughfare: String?

	// The city associated with the place.
	public let locality: String?

	// Additional city-level information for the place.
	public let subLocality: String?

	// The state or province associated with the place.
	public let administrativeArea: String?

	// Additional administrative area information for the place.
	public let subAdministrativeArea: String?

	// The postal code associated with the place.
	public let postalCode: String?

	public init(
		uuid: String,
		addedAt: Date,
		coordinate: Coordinate,
		name: String,
		phoneNumber: String?,
		url: URL?,
		category: PlaceCategory?,
		thoroughfare: String?,
		subThoroughfare: String?,
		locality: String?,
		subLocality: String?,
		administrativeArea: String?,
		subAdministrativeArea: String?,
		postalCode: String?
	) {
		self.uuid = uuid

		self.addedAt = addedAt
		self.coordinate = coordinate
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
}

extension Place: Hashable {
	public static func == (lhs: Place, rhs: Place) -> Bool {
		lhs.id == rhs.id
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
}

#if DEBUG
	public extension Place {
		static let preview = Place(
			uuid: UUID().uuidString,
			addedAt: Date(),
			coordinate: .init(latitude: 37.33233141, longitude: -122.03121860),
			name: "Test Location",
			phoneNumber: nil,
			url: nil,
			category: .park,
			thoroughfare: "123 Here St.",
			subThoroughfare: nil,
			locality: "Los Angeles",
			subLocality: nil,
			administrativeArea: "CA",
			subAdministrativeArea: nil,
			postalCode: "90120"
		)
	}
#endif
