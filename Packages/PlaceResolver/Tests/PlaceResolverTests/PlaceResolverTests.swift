//
//  PlaceResolverTests.swift
//  WhereWhenTests
//
//  Created by Pat Nakajima on 6/8/24.
//

import Database
import LibWhereWhen
import PlaceResolver
import XCTest

final class PlaceResolverTests: XCTestCase {
	var context: PlaceResolver.Context!

	override func setUp() async throws {
		context = .init(
			database: .memory,
			coordinate: Coordinate(37.32417350975213, -122.03711500556417)
		)

		try await context.database.reset()
	}

	@MainActor func testCanResolveLocal() async throws {
		let place1 = Place(
			uuid: UUID().uuidString,
			attribution: "Test",
			addedAt: Date(),
			coordinate: .init(latitude: 37.362795078216315, longitude: -122.02536098927486),
			name: "Hotel",
			phoneNumber: nil,
			url: nil,
			category: .hotel,
			thoroughfare: nil,
			subThoroughfare: nil,
			locality: nil,
			subLocality: nil,
			administrativeArea: nil,
			subAdministrativeArea: nil,
			postalCode: nil,
			isIgnored: false
		)

		let place2 = Place(
			uuid: UUID().uuidString,
			attribution: "Test",
			addedAt: Date(),
			coordinate: .init(latitude: 37.32417350975213, longitude: -122.03711500556417),
			name: "Target",
			phoneNumber: nil,
			url: nil,
			category: .parking,
			thoroughfare: nil,
			subThoroughfare: nil,
			locality: nil,
			subLocality: nil,
			administrativeArea: nil,
			subAdministrativeArea: nil,
			postalCode: nil,
			isIgnored: false
		)

		try! await place1.save(to: context.database)
		try! await place2.save(to: context.database)

		let count = try await Place.count(in: context.database)
		XCTAssertEqual(count, 2)

		let foundPlace = try await PlaceResolver.LocalDatabase(
			context: context
		).suggestions().first!.place

		XCTAssertEqual(foundPlace, place2)
	}
}
