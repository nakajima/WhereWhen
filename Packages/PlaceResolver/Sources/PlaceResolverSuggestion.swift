//
//  PlaceResolverSuggestion.swift
//
//
//  Created by Pat Nakajima on 6/13/24.
//
import Database
import GRDB
import LibWhereWhen

public extension PlaceResolver {
	struct Suggestion: Sendable, Identifiable {
		public var id: String { "\(source)-\(place.id)" }
		public let source: String
		public let place: Place
		public let confidence: Double

		public let context: PlaceResolver.Context

		var score: Double {
			// How far are we matters
			let distanceScore = 100_000.0 - place.coordinate.distance(to: context.coordinate)
			return distanceScore
		}
	}
}

extension PlaceResolver.Suggestion: Comparable {
	public static func == (lhs: PlaceResolver.Suggestion, rhs: PlaceResolver.Suggestion) -> Bool {
		lhs.place == rhs.place
	}

	public static func < (lhs: PlaceResolver.Suggestion, rhs: PlaceResolver.Suggestion) -> Bool {
		let lhsCheckinCount = lhs.place.checkinCount(in: lhs.context.database)
		let rhsCheckinCount = rhs.place.checkinCount(in: rhs.context.database)

		// If we've got checkins
		if lhsCheckinCount > 0 || rhsCheckinCount > 0 {
			return lhsCheckinCount < rhsCheckinCount
		}

		return lhs.score < rhs.score
	}
}
