//
//  Model.swift
//  WhereWhen
//
//  Created by Pat Nakajima on 6/7/24.
//

import Foundation
import GRDB

// Just a lil common interface around GRDB wrappers
public protocol Model: Sendable, TableRecord, FetchableRecord, PersistableRecord {
	var uuid: String { get }

	static var tableName: String { get }
	static func create(in db: Database) throws
}

public extension Model {
	static func `where`(_ predicate: SQLSpecificExpressible, in database: DatabaseContainer) throws -> [Self] {
		return try database.queue.read { db in
			try Self.filter(predicate).fetchAll(db)
		}
	}

	static func `where`<T: SQLSpecificExpressible & Sendable>(_ predicate: T, in database: DatabaseContainer) async throws -> [Self] {
		return try await database.queue.read { db in
			try Self.filter(predicate).fetchAll(db)
		}
	}

	static func count(in database: DatabaseContainer) throws -> Int {
		try database.queue.read { db in
			try Self.fetchCount(db)
		}
	}

	static func count(in database: DatabaseContainer) async throws -> Int {
		try await database.queue.read { db in
			try Self.fetchCount(db)
		}
	}

	static func all(in database: DatabaseContainer) throws -> [Self] {
		try database.queue.read { db in
			try Self.fetchAll(db)
		}
	}

	static func all(in database: DatabaseContainer) async throws -> [Self] {
		try await database.queue.read { db in
			try Self.fetchAll(db)
		}
	}

	func save(to database: DatabaseContainer) throws {
		try database.queue.write { db in
			try save(db)
		}
	}

	func save(to database: DatabaseContainer) async throws {
		try await database.queue.write { db in
			try! save(db)
		}
	}
}
