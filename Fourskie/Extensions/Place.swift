//
//  Place.swift
//  Fourskie
//
//  Created by Pat Nakajima on 6/5/24.
//

import Contacts
import Foundation
import LibFourskie
import MapKit

extension Place {
	var region: MKCoordinateRegion {
		MKCoordinateRegion(
			center: coordinate.clLocation,
			span: .within(meters: 50)
		)
	}

	func formatAddress() -> String {
		let postalAddress = CNMutablePostalAddress()

		if let thoroughfare = thoroughfare {
			postalAddress.street = thoroughfare
		}

		if let subThoroughfare = subThoroughfare {
			postalAddress.street += " \(subThoroughfare)"
		}

		if let locality = locality {
			postalAddress.city = locality
		}

		if let subLocality = subLocality {
			postalAddress.subLocality = subLocality
		}

		if let administrativeArea = administrativeArea {
			postalAddress.state = administrativeArea
		}

		if let subAdministrativeArea = subAdministrativeArea {
			postalAddress.subAdministrativeArea = subAdministrativeArea
		}

		if let postalCode = postalCode {
			postalAddress.postalCode = postalCode
		}

		let formatter = CNPostalAddressFormatter()
		let formattedAddress = formatter.string(from: postalAddress)

		return formattedAddress
	}
}
