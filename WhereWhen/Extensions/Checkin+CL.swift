//
//  Checkin+CL.swift
//  WhereWhen
//
//  Created by Pat Nakajima on 6/7/24.
//

import CoreLocation
import Foundation
import LibWhereWhen

extension Checkin {
	init(visit: CLVisit) {
		self.init(
			source: .automatic,
			uuid: UUID().uuidString,
			coordinate: .init(visit.coordinate),
			savedAt: Date(),
			accuracy: visit.horizontalAccuracy,
			arrivalDate: visit.arrivalDate,
			departureDate: visit.departureDate,
			place: nil
		)
	}
}
