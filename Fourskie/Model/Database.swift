//
//  Database.swift
//  Fourskie
//
//  Created by Pat Nakajima on 6/7/24.
//

import Foundation
import GRDB
import LibFourskie
import SwiftUI

struct DatabaseKey: EnvironmentKey {
	static let defaultValue: Database = .memory
}

private struct DatabaseQueueKey: EnvironmentKey {
	/// The default dbQueue is an empty in-memory database
	static var defaultValue: DatabaseQueue { try! DatabaseQueue() }
}

extension EnvironmentValues {
	var database: Database {
		get { self[DatabaseKey.self] }
		set { self[DatabaseKey.self] = newValue }
	}

	var dbQueue: DatabaseQueue {
		get { self[DatabaseQueueKey.self] }
		set { self[DatabaseQueueKey.self] = newValue }
	}
}

final class Database: Sendable {
	let queue: DatabaseQueue

	static let dev = Database(queue: try! DatabaseQueue(path: URL.documentsDirectory.appending(path: "fourskie-dev.sqlite").path))
	static let memory = Database(queue: try! DatabaseQueue())

	init(queue: DatabaseQueue) {
		self.queue = queue
		setup()
		print("DB: \(queue.path)")
	}

	func setup() {
		try! Place.create(in: self)
		try! Checkin.create(in: self)
		try! DeletedRecord.create(in: self)
	}

	func create(table: String, definition: (TableDefinition) throws -> Void) throws {
		try queue.write { db in
			try db.create(table: table, options: [.ifNotExists], body: definition)
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
