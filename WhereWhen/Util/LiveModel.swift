//
//  LiveModel.swift
//  WhereWhen
//
//  Created by Pat Nakajima on 6/7/24.
//

import Combine
import Database
import Foundation
import GRDB
import GRDBQuery
import LibWhereWhen
import Observation
import SwiftUI

@propertyWrapper struct LiveModel<ModelType: Model>: DynamicProperty, Sendable {
	@Environment(\.database) private var database: DatabaseContainer

	class Updater: ObservableObject {
		@Published var instance: ModelType
		var cancellable: AnyDatabaseCancellable?

		init(instance: ModelType) {
			self.instance = instance
		}

		func start(in database: DatabaseContainer) {
			if cancellable != nil { return }

			let uuid = instance.uuid

			let observation = ValueObservation.tracking { db in
				try ModelType.find(db, key: uuid)
			}

			cancellable = observation.start(in: database._queue) {
				print("LiveModel error: \($0)")
			} onChange: { [weak self] in
				guard let self else { return }
				self.instance = $0
			}
		}
	}

	@StateObject private var updater: Updater

	public func update() {
		updater.start(in: database)
	}

	var wrappedValue: ModelType {
		updater.instance
	}

	init(wrappedValue: ModelType) {
		self._updater = StateObject(wrappedValue: Updater(instance: wrappedValue))
	}
}

struct LiveModelQuery<ModelType: Model>: Queryable {
	static var defaultValue: ModelType { fatalError() }

	let uuid: String

	func publisher(in dbQueue: DatabaseQueue) -> AnyPublisher<ModelType, Error> {
		ValueObservation
			.tracking { db in
				try ModelType.find(db, key: uuid)
			}
			.publisher(in: dbQueue, scheduling: .immediate)
			.eraseToAnyPublisher()
	}
}
