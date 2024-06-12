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

	// Where did the data for this place come from?
	public var attribution: String?

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

	// Gets populated by DBs
	public var checkins: [Checkin] = []

	public var isIgnored: Bool = false

	public init(
		uuid: String,
		attribution: String?,
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
		postalCode: String?,
		isIgnored: Bool
	) {
		self.uuid = uuid
		self.attribution = attribution

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
		self.isIgnored = isIgnored
	}

	// Since places can come from multiple sources, we have to sort of
	// fudge this logic.
	public func same(as other: Place) -> Bool {
		coordinate == other.coordinate ||
			name == other.name
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
			attribution: "Preview",
			addedAt: Date(),
			coordinate: .init(latitude: 37.33233141, longitude: -122.03121860),
			name: "Test Location",
			phoneNumber: "5551231234",
			url: URL(string: "https://example.com"),
			category: .park,
			thoroughfare: "123 Here St.",
			subThoroughfare: nil,
			locality: "Los Angeles",
			subLocality: nil,
			administrativeArea: "CA",
			subAdministrativeArea: nil,
			postalCode: "90120",
			isIgnored: false
		)
	}
#endif
