//
//  ServerCheckin+Wrapper.swift
//
//
//  Created by Pat Nakajima on 6/5/24.
//

import Foundation
import LibWhereWhen

extension ServerCheckin: SharedWrapper {
	var wrapped: Checkin {
		Checkin(
			source: source,
			uuid: uuid,
			coordinate: .init(latitude: latitude, longitude: longitude),
			savedAt: savedAt,
			accuracy: accuracy,
			arrivalDate: arrivalDate,
			departureDate: departureDate,
			place: place?.wrapped
		)
	}

	init(wrapped: Checkin) {
		self.init(
			source: wrapped.source,
			uuid: wrapped.uuid,
			latitude: wrapped.coordinate.latitude,
			longitude: wrapped.coordinate.longitude,
			savedAt: wrapped.savedAt,
			accuracy: wrapped.accuracy,
			arrivalDate: wrapped.arrivalDate,
			departureDate: wrapped.departureDate,
			place: wrapped.place != nil ? ServerPlace(wrapped: wrapped.place!) : nil
		)
	}
}
