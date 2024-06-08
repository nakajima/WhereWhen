//
//  Model.swift
//  Fourskie
//
//  Created by Pat Nakajima on 6/7/24.
//

import Foundation
import GRDB
import LibFourskie

// Just a lil common interface around GRDB wrappers
protocol Model: Sendable, TableRecord, FetchableRecord, PersistableRecord {
	var uuid: String { get }

	static var tableName: String { get }
	static func create(in database: Database) throws
}

extension Model {
	static func `where`(_ predicate: SQLSpecificExpressible, in database: Database) throws -> [Self] {
		return try database.queue.read { db in
			try Self.filter(predicate).fetchAll(db)
		}
	}

	static func `where`<T: SQLSpecificExpressible & Sendable>(_ predicate: T, in database: Database) async throws -> [Self] {
		return try await database.queue.read { db in
			try Self.filter(predicate).fetchAll(db)
		}
	}

	static func count(in database: Database) throws -> Int {
		try database.queue.read { db in
			try Self.fetchCount(db)
		}
	}

	static func count(in database: Database) async throws -> Int {
		try await database.queue.read { db in
			try Self.fetchCount(db)
		}
	}

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

		if let spatialModel = self as? SpatialModel {
			try database.queue.spatialite { db in
				try db.execute(sql: spatialModel.coordinate.updateSQL(uuid: uuid, table: Self.tableName))
			}
		}
	}

	func save(to database: Database) async throws {
		try await database.queue.write { db in
			try save(db)
		}

		if let spatialModel = self as? SpatialModel {
			try database.queue.spatialite { db in
				try db.execute(sql: spatialModel.coordinate.updateSQL(uuid: uuid, table: Self.tableName))
			}
		}
	}
}
