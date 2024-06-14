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
	struct Suggestion: Sendable, Identifiable, Equatable {
		public static func == (lhs: Suggestion, rhs: Suggestion) -> Bool {
			lhs.id == rhs.id
		}

		public var id: String { "\(source)-\(place.id)" }
		public let source: String
		public let place: Place
		public let confidence: Double
		public let context: PlaceResolver.Context
	}
}
