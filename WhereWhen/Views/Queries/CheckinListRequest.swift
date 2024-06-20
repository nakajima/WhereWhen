//
//  CheckinListRequest.swift
//  WhereWhen
//
//  Created by Pat Nakajima on 6/7/24.
//

import Combine
import Foundation
import GRDB
import GRDBQuery
import LibWhereWhen

struct CheckinListRequest: Queryable {
	static var defaultValue: [Checkin] { [] }

	var unique: Bool = false

	init(unique: Bool = false) {
		self.unique = unique
	}

	func publisher(in dbQueue: DatabaseQueue) -> AnyPublisher<[Checkin], Error> {
		ValueObservation
			.tracking { db in
				var scope = Checkin
					.including(optional: Checkin.placeAssociation)
					.order(Column("savedAt").desc)

				if unique {
					scope = scope.select(literal: "DISTINCT placeID")
				}

				return try scope.fetchAll(db)
			}
			.publisher(in: dbQueue, scheduling: .immediate)
			.eraseToAnyPublisher()
	}
}
