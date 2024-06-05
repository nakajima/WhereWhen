//
//  File.swift
//
//
//  Created by Pat Nakajima on 6/5/24.
//

import Foundation

public struct Coordinate: Codable, Identifiable, Sendable {
	public var id: String { "\(latitude),\(longitude)" }

	public let latitude: Double
	public let longitude: Double

	public init(latitude: Double, longitude: Double) {
		self.latitude = latitude
		self.longitude = longitude
	}

	// Calculate distance between two coordinates using Haversine formula (according to chatgpt)
	public func distance(to other: Coordinate) -> Distance {
		let earthRadiusKm = 6371.0 // Earth's radius in kilometers
		let earthRadiusM = earthRadiusKm * 1000.0 // Earth's radius in meters

		let dLat = degreesToRadians(degrees: other.latitude - latitude)
		let dLon = degreesToRadians(degrees: other.longitude - longitude)

		let a = sin(dLat / 2) * sin(dLat / 2) +
			cos(degreesToRadians(degrees: latitude)) * cos(degreesToRadians(degrees: other.latitude)) *
			sin(dLon / 2) * sin(dLon / 2)
		let c = 2 * atan2(sqrt(a), sqrt(1 - a))

		let distance = earthRadiusM * c

		return distance
	}

	fileprivate func degreesToRadians(degrees: Double) -> Double {
		return degrees * .pi / 180
	}
}
