//
//  Place+CL.swift
//  WhereWhen
//
//  Created by Pat Nakajima on 6/5/24.
//

import Contacts
import Foundation
import LibWhereWhen
import MapKit

extension Place {
	init?(placemark: CLPlacemark?) {
		guard let placemark,
					let placemarkLocation = placemark.location,
					let placemarkName = placemark.name else {
			return nil
		}

		self.init(
			uuid: UUID().uuidString,
			addedAt: Date(),
			coordinate: .init(placemarkLocation.coordinate),
			name: placemarkName,
			phoneNumber: nil,
			url: nil,
			category: nil,
			thoroughfare: placemark.thoroughfare,
			subThoroughfare: placemark.subThoroughfare,
			locality: placemark.locality,
			subLocality: placemark.subLocality,
			administrativeArea: placemark.administrativeArea,
			subAdministrativeArea: placemark.subAdministrativeArea,
			postalCode: placemark.postalCode,
			isIgnored: false
		)
	}

	func region(_ span: MKCoordinateSpan) -> MKCoordinateRegion {
		MKCoordinateRegion(
			center: coordinate.clLocation,
			span: span
		)
	}

	func formatAddress() -> String {
		let postalAddress = CNMutablePostalAddress()

		postalAddress.street = [subThoroughfare, thoroughfare].compactMap { $0 }.joined(separator: " ")

		if let locality = locality {
			postalAddress.city = locality
		}

		if let subLocality = subLocality {
			postalAddress.subLocality = subLocality
		}

		if let administrativeArea = administrativeArea {
			postalAddress.state = administrativeArea
			postalAddress.state += ","
		}

		if let subAdministrativeArea = subAdministrativeArea {
			postalAddress.subAdministrativeArea = subAdministrativeArea
		}

		if let postalCode = postalCode {
			postalAddress.postalCode = postalCode
		}

		let formatter = CNPostalAddressFormatter()
		formatter.style = .mailingAddress
		let formattedAddress = formatter.string(from: postalAddress)

		return formattedAddress
	}
}
