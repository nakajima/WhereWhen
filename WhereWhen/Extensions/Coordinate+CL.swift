//
//  Coordinate+CL.swift
//  WhereWhen
//
//  Created by Pat Nakajima on 6/5/24.
//

import CoreLocation
import Foundation
import LibWhereWhen

extension Coordinate {
	var clLocation: CLLocationCoordinate2D {
		.init(latitude: latitude, longitude: longitude)
	}

	init(_ clCoordinate: CLLocationCoordinate2D) {
		self.init(
			latitude: clCoordinate.latitude,
			longitude: clCoordinate.longitude
		)
	}

	// Calculate distance between two coordinates using Haversine formula (according to chatgpt)
	public func distance(to other: Coordinate) -> Distance {
		CLLocation(latitude: latitude, longitude: longitude)
			.distance(from: CLLocation(latitude: other.latitude, longitude: other.longitude))
	}
}
