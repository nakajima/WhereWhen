//
//  Coordinate+CL.swift
//  Fourskie
//
//  Created by Pat Nakajima on 6/5/24.
//

import CoreLocation
import Foundation
import LibFourskie

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
}
