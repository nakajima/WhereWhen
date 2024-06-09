//
//  PlaceCheckinsRequest.swift
//  WhereWhen
//
//  Created by Pat Nakajima on 6/7/24.
//

import Combine
import Foundation
import GRDB
import GRDBQuery
import LibWhereWhen

struct PlaceCheckinsRequest: Queryable {
	static var defaultValue: [Checkin] { [] }

	var placeUUID: String

	func publisher(in dbQueue: DatabaseQueue) -> AnyPublisher<[Checkin], Error> {
		ValueObservation
			.tracking { db in
				try Checkin
					.filter(Column("placeID") == placeUUID)
					.order(Column("savedAt").desc)
					.fetchAll(db)
			}
			.publisher(in: dbQueue, scheduling: .immediate)
			.eraseToAnyPublisher()
	}
}
