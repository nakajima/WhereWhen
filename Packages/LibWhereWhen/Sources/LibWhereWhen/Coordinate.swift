//
//  Coordinate.swift
//
//
//  Created by Pat Nakajima on 6/5/24.
//

import Foundation

public struct Coordinate: Codable, Identifiable, Sendable, Equatable, Hashable {
	static let currentPlanetRadiusMeters = 6371.0 * 1000.0 // hardcoding "earth" here

	public enum Offset {
		// Define the prefix - operator
		public static prefix func - (offset: Offset) -> Offset {
			switch offset {
			case let .meters(value): .meters(-value)
			}
		}

		case meters(Double)

		public var meters: Double {
			switch self {
			case let .meters(value): value
			}
		}
	}

	public var id: String { "\(latitude),\(longitude)" }

	public let latitude: Double
	public let longitude: Double

	public init(_ latitude: Double, _ longitude: Double) {
		self.latitude = latitude
		self.longitude = longitude
	}

	public init(latitude: Double, longitude: Double) {
		self.latitude = latitude
		self.longitude = longitude
	}

	// Calculate distance between two coordinates using Haversine formula (according to chatgpt)
	public func distance(to other: Coordinate) -> Distance {
		let dLat = degreesToRadians(degrees: other.latitude - latitude)
		let dLon = degreesToRadians(degrees: other.longitude - longitude)

		let a = sin(dLat / 2) * sin(dLat / 2) +
			cos(degreesToRadians(degrees: latitude)) * cos(degreesToRadians(degrees: other.latitude)) *
			sin(dLon / 2) * sin(dLon / 2)
		let c = 2 * atan2(sqrt(a), sqrt(1 - a))

		let distance = Self.currentPlanetRadiusMeters * c

		return distance
	}

	public func offset(x: Offset, y: Offset) -> Coordinate {
		var dLat = 0.0
		var dLon = 0.0

		switch x {
		case let .meters(distanceX):
			dLon = distanceX / (Self.currentPlanetRadiusMeters * cos(degreesToRadians(degrees: latitude)))
		}

		switch y {
		case let .meters(distanceY):
			dLat = distanceY / Self.currentPlanetRadiusMeters
		}

		let newLatitude = latitude + radiansToDegrees(radians: dLat)
		let newLongitude = longitude + radiansToDegrees(radians: dLon)

		return Coordinate(latitude: newLatitude, longitude: newLongitude)
	}

	fileprivate func degreesToRadians(degrees: Double) -> Double {
		return degrees * .pi / 180
	}

	fileprivate func radiansToDegrees(radians: Double) -> Double {
		return radians * 180 / .pi
	}
}
