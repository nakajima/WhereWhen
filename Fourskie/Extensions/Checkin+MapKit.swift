//
//  Checkin+MapKit.swift
//  Fourskie
//
//  Created by Pat Nakajima on 6/6/24.
//

import Foundation
import LibFourskie
import MapKit

extension Checkin {
	func region(_ span: MKCoordinateSpan) -> MKCoordinateRegion {
		MKCoordinateRegion(
			center: coordinate.clLocation,
			span: span
		)
	}
}
