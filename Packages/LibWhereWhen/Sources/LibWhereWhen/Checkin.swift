//
//  Checkin.swift
//
//
//  Created by Pat Nakajima on 6/4/24.
//

import Foundation

public struct Checkin: Identifiable, Codable, Sendable, Hashable {
	public var id: String { uuid }

	public let source: CheckinSource

	// A unique ID shared across client/server
	public let uuid: String

	// Where was this checkin recorded
	public var coordinate: Coordinate

	// When was this checkin recorded
	public private(set) var savedAt: Date

	// What accuracy did we get back from CoreLocation
	public let accuracy: Double

	// Unreliable timestmaps from CoreLocation
	public let arrivalDate: Date?
	public let departureDate: Date?

	// Do we have a place?
	public var place: Place?

	public init(
		source: CheckinSource,
		uuid: String,
		coordinate: Coordinate,
		savedAt: Date,
		accuracy: Double,
		arrivalDate: Date?,
		departureDate: Date?,
		place: Place?
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

#if DEBUG
	public extension Checkin {
		static let preview = Checkin(
			source: .manual,
			uuid: UUID().uuidString,
			coordinate: Place.preview.coordinate,
			savedAt: Date().addingTimeInterval(-100),
			accuracy: 12,
			arrivalDate: Date().addingTimeInterval(-100),
			departureDate: Date().addingTimeInterval(-100),
			place: Place.preview
		)

		static func makePreview(block: ((inout Checkin) -> Void)? = nil) -> Checkin {
			var checkin = Checkin(
				source: .automatic,
				uuid: UUID().uuidString,
				coordinate: Place.preview.coordinate,
				savedAt: Date().addingTimeInterval(-100),
				accuracy: 12,
				arrivalDate: Date().addingTimeInterval(-100),
				departureDate: Date().addingTimeInterval(-100),
				place: Place.preview
			)

			if let block {
				block(&checkin)
			}

			return checkin
		}

		subscript<T>(_ keyPath: PartialKeyPath<Checkin>) -> T {
			get {
				self[keyPath: keyPath] as! T
			}

			set {
				self[keyPath: keyPath as! WritableKeyPath<Checkin, T>] = newValue
			}
		}
	}
#endif
