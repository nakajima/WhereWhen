//
//  LocalPlace+Wrapper.swift
//  Fourskie
//
//  Created by Pat Nakajima on 6/5/24.
//

import Foundation
import LibFourskie

extension LocalPlace: SharedWrapper {
	typealias Wrapped = Place

	convenience init(wrapped: Place) {
		self.init(
			uuid: wrapped.uuid,
			addedAt: wrapped.addedAt,
			coordinate: wrapped.coordinate,
			name: wrapped.name,
			phoneNumber: wrapped.phoneNumber,
			url: wrapped.url,
			category: wrapped.category,
			thoroughfare: wrapped.thoroughfare,
			subThoroughfare: wrapped.subThoroughfare,
			locality: wrapped.locality,
			subLocality: wrapped.subLocality,
			administrativeArea: wrapped.administrativeArea,
			subAdministrativeArea: wrapped.subAdministrativeArea,
			postalCode: wrapped.postalCode
		)
	}

	var wrapped: Place {
		Place(
			uuid: uuid,
			addedAt: addedAt,
			coordinate: coordinate,
			name: name,
			phoneNumber: phoneNumber,
			url: url,
			category: category,
			thoroughfare: thoroughfare,
			subThoroughfare: subThoroughfare,
			locality: locality,
			subLocality: subLocality,
			administrativeArea: administrativeArea,
			subAdministrativeArea: subAdministrativeArea,
			postalCode: postalCode
		)
	}
}
