//
//  File.swift
//  
//
//  Created by Pat Nakajima on 6/5/24.
//

import Foundation
import LibFourskie

extension ServerPlace: SharedWrapper {
	init(wrapped: Place) {
		self.init(
			uuid: wrapped.uuid,
			coordinateID: wrapped.coordinate.id,
			addedAt: wrapped.addedAt,
			latitude: wrapped.coordinate.latitude,
			longitude: wrapped.coordinate.longitude,
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
			coordinate: .init(latitude: latitude, longitude: longitude),
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
