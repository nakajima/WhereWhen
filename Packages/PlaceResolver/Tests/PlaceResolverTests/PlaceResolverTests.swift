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
	var database: DatabaseContainer!

	@MainActor override func setUp() async throws {
		try? FileManager.default.removeItem(at: URL.documentsDirectory.appending(path: "test.sqlite"))

		database = DatabaseContainer.create(.path("test.sqlite"), for: DatabaseContainer.defaultModels)
	}

	@MainActor func testCanResolveLocal() async throws {
		let place1 = Place(
			uuid: UUID().uuidString,
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

		try! await place1.save(to: database)
		try! await place2.save(to: database)

		let count = try await Place.count(in: database)
		XCTAssertEqual(count, 2)

		let nearby: Coordinate = .init(37.32417350975213, -122.03711500556417)

		let foundPlace = try await PlaceResolver.LocalDatabase(
			database: database,
			coordinate: nearby
		).place()

		XCTAssertEqual(foundPlace, place2)
	}
}
