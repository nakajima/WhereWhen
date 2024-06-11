//
//  DatabaseContainer.swift
//  WhereWhen
//
//  Created by Pat Nakajima on 6/7/24.
//

import Foundation
import GRDB
import LibWhereWhen

public final class DatabaseContainer: Sendable {
	let queue: DatabaseQueue
	let models: [any Model.Type]

	public static let defaultModels: [any Model.Type] = [
		Place.self,
		Checkin.self,
		DeletedRecord.self,
	]

	public enum Name {
		case path(String), memory
	}

	public static func create(_ name: Name, for models: [any Model.Type]) -> DatabaseContainer {
		var config = Configuration()

		// This isn't working reliably
		config.prepareDatabase { db in
			#if DEBUG
				db.trace { event in
					if case let .statement(statement) = event {
						print(statement.expandedSQL)
					}
				}
			#endif
		}

		#if DEBUG
			// Protect sensitive information by enabling verbose debugging in DEBUG builds only
			config.publicStatementArguments = true
		#endif

		if case let .path(name) = name {
			let path = URL.documentsDirectory.appending(path: name).path
			// It can be helpful to know where the db is
			print("DB: \(path)")

			let queue = try! DatabaseQueue(path: path, configuration: config)
			return DatabaseContainer(
				queue: queue,
				models: models
			)
		} else {
			let queue = try! DatabaseQueue(configuration: config)
			return DatabaseContainer(
				queue: queue,
				models: models
			)
		}
	}

	init(queue: DatabaseQueue, models: [any Model.Type]) {
		self.queue = queue
		self.models = models

		setupTables()
	}

	var url: URL {
		URL.documentsDirectory.appending(path: queue.path)
	}

	func setupTables() {
		for model in models {
			try! queue.write { db in
				try! model.create(in: db)
			}
		}
	}
}

// Commonly used
public extension DatabaseContainer {
	static let dev = create(
		.path("wherewhendev.sqlite"),
		for: [Place.self, Checkin.self, DeletedRecord.self]
	)
	static let memory = create(
		.memory,
		for: [Place.self, Checkin.self, DeletedRecord.self]
	)
}

// GRDB Wrappers
public extension DatabaseContainer {
	// Sometimes we need it...
	var _queue: DatabaseQueue { queue }

	func read<T>(updates: (Database) throws -> T) throws -> T {
		try queue.read { db in
			try updates(db)
		}
	}

	func read<T>(updates: @Sendable @escaping (Database) throws -> T) async throws -> T {
		try await queue.read { db in
			try updates(db)
		}
	}

	func write<T>(updates: (Database) throws -> T) throws -> T {
		try queue.write { db in
			try updates(db)
		}
	}

	func write<T>(updates: @Sendable @escaping (Database) throws -> T) async throws -> T {
		try await queue.write { db in
			try updates(db)
		}
	}

	func delete(_ model: Model) throws {
		_ = try queue.write { db in
			if let deleteSyncable = model as? DeleteSyncable {
				let record = DeletedRecord(uuid: deleteSyncable.uuid, type: String(describing: type(of: model)), deletedAt: Date())
				try record.insert(db)
			}

			try model.delete(db)
		}
	}
}
