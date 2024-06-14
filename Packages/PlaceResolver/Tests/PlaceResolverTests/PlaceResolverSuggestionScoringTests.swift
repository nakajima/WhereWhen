//
//  PlaceResolverSuggestionScoringTests.swift
//  WhereWhenTests
//
//  Created by Pat Nakajima on 6/8/24.
//

import Database
import LibWhereWhen
@testable import PlaceResolver // So we can init suggestions
import XCTest

final class PlaceResolverSuggestionTests: XCTestCase {
	var context: PlaceResolver.Context!

	override func setUp() async throws {
		context = .init(
			database: .memory,
			coordinate: Coordinate(37.32417350975213, -122.03711500556417)
		)
	}

	func sorter(_ suggestions: PlaceResolver.Suggestion...) -> [PlaceResolver.Suggestion] {
		try! PlaceResolver.Suggestion.Sorter(context: context, suggestions: suggestions).sorted()
	}

	func testSuggestionScoresCloserHigher() throws {
		let place1 = Place.makePreview {
			$0[\.coordinate] = self.context.coordinate.offset(x: .meters(10), y: .meters(10))
		}

		let place2 = Place.makePreview {
			$0[\.coordinate] = self.context.coordinate.offset(x: .meters(5), y: .meters(5))
		}

		// All else equal........
		let suggestion1 = PlaceResolver.Suggestion(source: "Test", place: place1, confidence: 1, context: context)
		let suggestion2 = PlaceResolver.Suggestion(source: "Test", place: place2, confidence: 1, context: context)

		XCTAssertEqual(
			sorter(suggestion1, suggestion2),
			[suggestion2, suggestion1]
		)
	}

	func testSuggestionCheckinCountScoresHigherThanDistance() throws {
		let place1 = Place.makePreview {
			$0[\.coordinate] = self.context.coordinate.offset(x: .meters(10), y: .meters(10))
		}

		let checkin = Checkin.makePreview {
			$0.place = place1
		}

		try! checkin.save(to: context.database)

		let place2 = Place.makePreview {
			$0[\.coordinate] = self.context.coordinate.offset(x: .meters(5), y: .meters(5))
		}

		// All else equal........
		let suggestion1 = PlaceResolver.Suggestion(source: "Test", place: place1, confidence: 1, context: context)
		let suggestion2 = PlaceResolver.Suggestion(source: "Test", place: place2, confidence: 1, context: context)

		XCTAssertEqual(
			sorter(suggestion2, suggestion1),

			// place1 has more checkins than place2 so it gets a higher score
			[suggestion1, suggestion2]
		)
	}
}
