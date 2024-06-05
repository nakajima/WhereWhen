//
//  LocalCheckin+Wrapper.swift
//  Fourskie
//
//  Created by Pat Nakajima on 6/5/24.
//

import Foundation
import LibFourskie

extension LocalCheckin: SharedWrapper {
	typealias Wrapped = Checkin

	var wrapped: Checkin {
		Checkin(
			source: source,
			uuid: uuid,
			coordinate: coordinate,
			savedAt: savedAt,
			accuracy: accuracy,
			arrivalDate: arrivalDate,
			departureDate: departureDate,
			place: place?.wrapped
		)
	}

	convenience init(wrapped: Checkin) {
		self.init(
			source: wrapped.source,
			uuid: wrapped.uuid,
			coordinate: wrapped.coordinate,
			savedAt: wrapped.savedAt,
			accuracy: wrapped.accuracy,
			arrivalDate: wrapped.arrivalDate,
			departureDate: wrapped.departureDate,
			place: wrapped.place != nil ? LocalPlace(wrapped: wrapped.place!) : nil
		)
	}
}
