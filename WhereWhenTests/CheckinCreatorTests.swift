//
//  CheckinCreatorTests.swift
//  WhereWhenTests
//
//  Created by Pat Nakajima on 6/8/24.
//

import LibWhereWhen
@testable import WhereWhen
import XCTest

final class CheckinCreatorTests: XCTestCase {
	var database: Database!

	override func setUp() async throws {
		database = Database.create(.memory)
	}

	func testWorks() async throws {
		let checkin = Checkin.preview

		try await CheckinCreator(checkin: checkin, database: database).create(place: nil)

		let list = try await Checkin.all(in: database)
		XCTAssertEqual(list.count, 1, "\(list.map(\.place))")
	}

	func testDoesNotCreateIfCloseToIgnoredPlace() async throws {
		let checkin = Checkin.preview
		try await checkin.save(to: database)

		var place = checkin.place! // we know we have one since it's from .preview
		place.isIgnored = true
		try await place.save(to: database)

		let uuid = place.uuid
		let isIgnored = try await database.queue.read { try Place.find($0, id: uuid).isIgnored }
		XCTAssert(isIgnored, "did not set ignored properly")

		let newCheckin = Checkin.makePreview { $0.coordinate = checkin.coordinate.offset(x: .meters(5), y: .meters(5)) }
		try await CheckinCreator(checkin: newCheckin, database: database).create(place: nil)

		let count = try await Checkin.count(in: database)
		XCTAssertEqual(count, 1)
	}
}
