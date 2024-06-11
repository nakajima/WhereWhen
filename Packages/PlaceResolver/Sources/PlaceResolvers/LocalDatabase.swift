//
//  LocalDatabase.swift
//  WhereWhen
//
//  Created by Pat Nakajima on 6/9/24.
//

import Database
import Foundation
import GRDB
import LibWhereWhen

public struct SpatialQuery: SQLSpecificExpressible {
	public var sqlExpression: GRDB.SQLExpression {
		SQL(
			sql: "latitude > ? AND latitude < ? AND longitude > ? AND longitude < ?",
			arguments: [bounds.minY, bounds.maxY, bounds.minX, bounds.maxX]
		).sqlExpression
	}

	let coordinate: Coordinate
	let span: Coordinate.Offset
	public var bounds: CGRect

	public init(coordinate: Coordinate, span: Coordinate.Offset) {
		self.coordinate = coordinate
		self.span = span

		let topLeading = coordinate.offset(x: -span, y: -span)
		self.bounds = .init(
			x: topLeading.longitude,
			y: topLeading.latitude,
			width: span.meters * 2.0,
			height: span.meters * 2.0
		)
	}
}

public extension PlaceResolver {
	struct LocalDatabase: Resolver {
		let database: DatabaseContainer
		let coordinate: Coordinate

		public init(database: DatabaseContainer, coordinate: Coordinate) {
			self.database = database
			self.coordinate = coordinate
		}

		@MainActor public func suggestion() async throws -> Suggestion? {
			let query = SpatialQuery(coordinate: coordinate, span: .meters(10))
			let places = try await Place.where(query, in: database)

			let firstPlace = places.sorted(by: {
				$0.coordinate.distance(to: coordinate) <
					$1.coordinate.distance(to: coordinate)
			}).first

			if let firstPlace {
				return .init(source: "Local DB", place: firstPlace, confidence: 10)
			}

			return nil
		}
	}
}
