//
//  Address.swift
//  WhereWhen
//
//  Created by Pat Nakajima on 6/14/24.
//

import Foundation
import LibWhereWhen
import Observation
import SwiftUI

@Observable class Address {
	var thoroughfare: String = ""
	var subThoroughfare: String = ""
	var locality: String = ""
	var subLocality: String = ""
	var administrativeArea: String = ""
	var subAdministrativeArea: String = ""
	var postalCode: String = ""

	var street: String {
		get {
			return [subThoroughfare, thoroughfare].compactMap { $0.presence }.joined(separator: " ")
		}
		set {
			let parts = newValue.split(separator: #/\s+/#, maxSplits: 1)
			switch parts.count {
			case 0:
				subThoroughfare = ""
				thoroughfare = ""
			case 1:
				thoroughfare = newValue
			default:
				subThoroughfare = String(parts[0])
				thoroughfare = String(parts[1])
			}
		}
	}

	convenience init(place: Place) {
		self.init(
			thoroughfare: place.thoroughfare,
			subThoroughfare: place.subThoroughfare,
			locality: place.locality,
			subLocality: place.subLocality,
			administrativeArea: place.administrativeArea,
			subAdministrativeArea: place.subAdministrativeArea,
			postalCode: place.postalCode
		)
	}

	init(
		thoroughfare: String? = nil,
		subThoroughfare: String? = nil,
		locality: String? = nil,
		subLocality: String? = nil,
		administrativeArea: String? = nil,
		subAdministrativeArea: String? = nil,
		postalCode: String? = nil
	) {
		self.thoroughfare = thoroughfare ?? ""
		self.subThoroughfare = subThoroughfare ?? ""
		self.locality = locality ?? ""
		self.subLocality = subLocality ?? ""
		self.administrativeArea = administrativeArea ?? ""
		self.subAdministrativeArea = subAdministrativeArea ?? ""
		self.postalCode = postalCode ?? ""
	}
}
