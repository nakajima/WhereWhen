//
//  Category.swift
//
//
//  Created by Pat Nakajima on 6/5/24.
//

import Foundation

public enum PlaceCategory: String, Codable, Sendable {
	case airport
	case amusementPark
	case aquarium
	case atm
	case bakery
	case bank
	case beach
	case brewery
	case cafe
	case campground
	case carRental
	case evCharger
	case fireStation
	case fitnessCenter
	case foodMarket
	case gasStation
	case hospital
	case hotel
	case laundry
	case library
	case marina
	case movieTheater
	case museum
	case nationalPark
	case nightlife
	case park
	case parking
	case pharmacy
	case police
	case postOffice
	case publicTransport
	case restaurant
	case restroom
	case school
	case stadium
	case store
	case theater
	case university
	case winery
	case zoo

	case unknown
}

extension PlaceCategory: CustomStringConvertible {
	public var description: String {
		rawValue.replacing(#/([A-Z])/#) { " \($0.output.1)" }.capitalized
	}
}
