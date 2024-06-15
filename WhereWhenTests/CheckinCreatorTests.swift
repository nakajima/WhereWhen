//
//  CheckinCreatorTests.swift
//  WhereWhenTests
//
//  Created by Pat Nakajima on 6/8/24.
//

import Database
import LibWhereWhen
@testable import WhereWhen
import XCTest

final class CheckinCreatorTests: XCTestCase {
	var database: DatabaseContainer!

	override func setUp() async throws {
		database = DatabaseContainer.create(.memory, for: DatabaseContainer.defaultModels)
	}

	func testWorks() async throws {
		let checkin = Checkin.preview

		try await CheckinCreator(checkin: checkin, database: database).create(place: nil)

		let list = try await Checkin.all(in: database)
		XCTAssertEqual(list.count, 1, "\(list)")
	}

	func testDoesNotCreateIfCloseToIgnoredPlace() async throws {
		let checkin = Checkin.preview
		try await checkin.save(to: database)

		var place = checkin.place! // we know we have one since it's from .preview
		place.isIgnored = true
		try await place.save(to: database)

		let uuid = place.uuid
		let isIgnored = try await database.read { try Place.find($0, key: uuid).isIgnored }
		XCTAssert(isIgnored, "did not set ignored properly")

		let newCheckin = Checkin.makePreview { $0.coordinate = checkin.coordinate.offset(x: .meters(5), y: .meters(5)) }
		try await CheckinCreator(checkin: newCheckin, database: database).create(place: nil)

		let count = try await Checkin.count(in: database)
		XCTAssertEqual(count, 1)
	}

	func testDoesNotCreateIfSamePlace() async throws {
		let place = Place.preview
		try await place.save(to: database)

		let checkin = Checkin.makePreview {
			// Five minutes ago
			$0.place = place
			$0[\.savedAt] = Date().addingTimeInterval(-60 * 5)
		}
		try await checkin.save(to: database)

		let newCheckin = Checkin.makePreview {
			$0.place = place
		}

		try await CheckinCreator(
			checkin: newCheckin,
			database: database
		).create(place: checkin.place!)

		let count = try await Checkin.count(in: database)
		XCTAssertEqual(count, 1)
	}

	func testDoesCreateIfSamePlaceAndItsBeen24Hours() async throws {
		let place = Place.preview
		try await place.save(to: database)

		let checkin = Checkin.makePreview {
			// 25 hours ago
			$0.place = place
			$0[\.savedAt] = Date().addingTimeInterval(-60 * 60 * 25)
		}
		try await checkin.save(to: database)

		let newCheckin = Checkin.makePreview {
			$0.place = place
		}

		try await CheckinCreator(
			checkin: newCheckin,
			database: database
		).create(place: checkin.place!)

		let count = try await Checkin.count(in: database)
		XCTAssertEqual(count, 2)
	}
}
