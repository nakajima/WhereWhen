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
		let bottomTrailing = coordinate.offset(x: span, y: span)
		self.bounds = .init(
			x: topLeading.longitude,
			y: topLeading.latitude,
			width: bottomTrailing.longitude - topLeading.longitude,
			height: bottomTrailing.latitude - topLeading.latitude
		)
	}
}

public extension PlaceResolver {
	struct LocalDatabase: Resolver {
		public let context: Context

		public init(context: Context) {
			self.context = context
		}

		@MainActor public func suggestions() async throws -> [Suggestion] {
			let query = SpatialQuery(coordinate: context.coordinate, span: .meters(10))
			let places = try await Place.where(query, in: context.database)

			return places.sorted(by: {
				$0.coordinate.distance(to: context.coordinate) <
					$1.coordinate.distance(to: context.coordinate)
			}).map {
				.init(source: "Local", place: $0, confidence: 10, context: context)
			}
		}
	}
}
