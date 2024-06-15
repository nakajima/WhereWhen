//
//  Place.swift
//
//
//  Created by Pat Nakajima on 6/5/24.
//

import Foundation

// Places. This is basically a wrapper around CLPlacemark
public struct Place: Codable, Identifiable, Sendable, Equatable {
	public var id: [String] {
		[
			uuid,
			String(coordinate.latitude),
			String(coordinate.longitude),
			name,
			category?.rawValue,
			phoneNumber,
			url?.absoluteString,
			subThoroughfare,
			thoroughfare,
			subLocality,
			locality,
			administrativeArea,
			subAdministrativeArea,
			postalCode,
			isIgnored ? "1" : "0",
		].compactMap { $0 }
	}

	// Where did the data for this place come from?
	public var attribution: String?

	public let uuid: String

	// When was this place added
	public let addedAt: Date

	// The lat/lng of the place
	public var coordinate: Coordinate

	public var category: PlaceCategory?

	// The name of the place.
	public var name: String

	// The phone number of the place
	public var phoneNumber: String?

	// The website
	public var url: URL?

	// The street address associated with the place.
	public var thoroughfare: String?

	// Additional street-level information for the place.
	public var subThoroughfare: String?

	// The city associated with the place.
	public var locality: String?

	// Additional city-level information for the place.
	public var subLocality: String?

	// The state or province associated with the place.
	public var administrativeArea: String?

	// Additional administrative area information for the place.
	public var subAdministrativeArea: String?

	// The postal code associated with the place.
	public var postalCode: String?

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
			phoneNumber: "(555) 123-1234",
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

		static func makePreview(block: ((inout Place) -> Void)? = nil) -> Place {
			var place = Place(
				uuid: UUID().uuidString,
				attribution: "Preview",
				addedAt: Date(),
				coordinate: .init(latitude: 37.33233141, longitude: -122.03121860),
				name: "Test Location",
				phoneNumber: "(555) 123-1234",
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

			if let block {
				block(&place)
			}

			return place
		}

		// Lets us mess with let properties in the makePreview setup block
		subscript<T>(_ keyPath: PartialKeyPath<Place>) -> T {
			get {
				self[keyPath: keyPath] as! T
			}

			set {
				self[keyPath: keyPath as! WritableKeyPath<Place, T>] = newValue
			}
		}
	}
#endif
