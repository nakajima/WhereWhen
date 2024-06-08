//
//  Model.swift
//  Fourskie
//
//  Created by Pat Nakajima on 6/7/24.
//

import Foundation
import GRDB

// Just a lil common interface around GRDB wrappers
protocol Model: Sendable, TableRecord, FetchableRecord, PersistableRecord {
	var uuid: String { get }

	static func create(in database: Database) throws
}

extension Model {
	static func all(in database: Database) throws -> [Self] {
		try database.queue.read { db in
			try Self.fetchAll(db)
		}
	}

	static func all(in database: Database) async throws -> [Self] {
		try await database.queue.read { db in
			try Self.fetchAll(db)
		}
	}

	func save(to database: Database) throws {
		try database.queue.write { db in
			try save(db)
		}
	}

	func save(to database: Database) async throws {
		try await database.queue.write { db in
			try save(db)
		}
	}
}
