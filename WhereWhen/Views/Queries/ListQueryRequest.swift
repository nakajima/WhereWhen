//
//  ListQueryRequest.swift
//  WhereWhen
//
//  Created by Pat Nakajima on 6/7/24.
//

import Combine
import Foundation
import GRDB
import GRDBQuery

struct ListQueryRequest<ModelType: Model>: Queryable {
	static var defaultValue: [ModelType] { [] }

	func publisher(in dbQueue: DatabaseQueue) -> AnyPublisher<[ModelType], Error> {
		ValueObservation
			.tracking { db in try ModelType.fetchAll(db) }
			// The `.immediate` scheduling feeds the view right on subscription,
			// and avoids an initial rendering with an empty list:
			.publisher(in: dbQueue, scheduling: .immediate)
			.eraseToAnyPublisher()
	}
}
