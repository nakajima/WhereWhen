//
//  IgnoredPlacesRequest.swift
//  Fourskie
//
//  Created by Pat Nakajima on 6/7/24.
//

import Combine
import Foundation
import GRDB
import GRDBQuery
import LibFourskie

struct IgnoredPlacesRequest: Queryable {
	static var defaultValue: [Place] { [] }

	func publisher(in dbQueue: DatabaseQueue) -> AnyPublisher<[Place], Error> {
		ValueObservation
			.tracking { db in try Place.filter(Column("isIgnored") == true).fetchAll(db) }
			// The `.immediate` scheduling feeds the view right on subscription,
			// and avoids an initial rendering with an empty list:
			.publisher(in: dbQueue, scheduling: .immediate)
			.eraseToAnyPublisher()
	}
}
