//
//  MKPointOfInterestCategory.swift
//  Fourskie
//
//  Created by Pat Nakajima on 6/5/24.
//

import Foundation
import LibFourskie
import MapKit

extension MKPointOfInterestCategory: SharedWrapper {
	public typealias Wrapped = PlaceCategory

	public var wrapped: PlaceCategory {
		switch self {
		case .airport: .airport
		case .amusementPark: .amusementPark
		case .aquarium: .aquarium
		case .atm: .atm
		case .bakery: .bakery
		case .bank: .bank
		case .beach: .beach
		case .brewery: .brewery
		case .cafe: .cafe
		case .campground: .campground
		case .carRental: .carRental
		case .evCharger: .evCharger
		case .fireStation: .fireStation
		case .fitnessCenter: .fitnessCenter
		case .foodMarket: .foodMarket
		case .gasStation: .gasStation
		case .hospital: .hospital
		case .hotel: .hotel
		case .laundry: .laundry
		case .library: .library
		case .marina: .marina
		case .movieTheater: .movieTheater
		case .museum: .museum
		case .nationalPark: .nationalPark
		case .nightlife: .nightlife
		case .park: .park
		case .parking: .parking
		case .pharmacy: .pharmacy
		case .police: .police
		case .postOffice: .postOffice
		case .publicTransport: .publicTransport
		case .restaurant: .restaurant
		case .restroom: .restroom
		case .school: .school
		case .stadium: .stadium
		case .store: .store
		case .theater: .theater
		case .university: .university
		case .winery: .winery
		case .zoo: .zoo
		default:
				.unknown
		}
	}

	public init?(wrapped: PlaceCategory) {
		let mapped: MKPointOfInterestCategory? = switch wrapped {
		case .airport: .airport
		case .amusementPark: .amusementPark
		case .aquarium: .aquarium
		case .atm: .atm
		case .bakery: .bakery
		case .bank: .bank
		case .beach: .beach
		case .brewery: .brewery
		case .cafe: .cafe
		case .campground: .campground
		case .carRental: .carRental
		case .evCharger: .evCharger
		case .fireStation: .fireStation
		case .fitnessCenter: .fitnessCenter
		case .foodMarket: .foodMarket
		case .gasStation: .gasStation
		case .hospital: .hospital
		case .hotel: .hotel
		case .laundry: .laundry
		case .library: .library
		case .marina: .marina
		case .movieTheater: .movieTheater
		case .museum: .museum
		case .nationalPark: .nationalPark
		case .nightlife: .nightlife
		case .park: .park
		case .parking: .parking
		case .pharmacy: .pharmacy
		case .police: .police
		case .postOffice: .postOffice
		case .publicTransport: .publicTransport
		case .restaurant: .restaurant
		case .restroom: .restroom
		case .school: .school
		case .stadium: .stadium
		case .store: .store
		case .theater: .theater
		case .university: .university
		case .winery: .winery
		case .zoo: .zoo
		default:
			nil
		}

		if let mapped {
			self = mapped
		} else {
			return nil
		}
	}
}
