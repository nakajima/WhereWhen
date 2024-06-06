//
//  MKCoordinateSpan+Constants.swift
//  Fourskie
//
//  Created by Pat Nakajima on 6/5/24.
//

import Foundation
import MapKit

extension MKCoordinateSpan {
	static func within(meters: Double) -> MKCoordinateSpan {
		MKCoordinateSpan(
			latitudeDelta: meters / 111_000.0,
			longitudeDelta: meters / 111_000.0
		)
	}
}
