//
//  CLError.swift
//  WhereWhen
//
//  Created by Pat Nakajima on 6/20/24.
//

import CoreLocation
import Foundation

extension CLError {
	var description: String {
		switch code {
		case .locationUnknown:
			"The location is currently unknown."
		case .denied:
			"Access to location services is denied."
		case .network:
			"The network is unavailable or a network error occurred."
		case .headingFailure:
			"The heading could not be determined."
		default:
			localizedDescription
		}
	}
}
