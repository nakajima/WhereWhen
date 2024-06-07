//
//  CheckinListRequest.swift
//  Fourskie
//
//  Created by Pat Nakajima on 6/7/24.
//

import Combine
import Foundation
import GRDB
import GRDBQuery
import LibFourskie

struct CheckinListRequest: Queryable {
	static var defaultValue: [Checkin] { [] }

	func publisher(in dbQueue: DatabaseQueue) -> AnyPublisher<[Checkin], Error> {
		ValueObservation
			.tracking { db in
				try Checkin
					.including(optional: Checkin.placeAssociation)
					.order(Column("savedAt").desc)
					.fetchAll(db)
			}
			.publisher(in: dbQueue, scheduling: .immediate)
			.eraseToAnyPublisher()
	}
}
