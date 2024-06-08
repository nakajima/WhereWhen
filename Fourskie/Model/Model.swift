//
//  Model.swift
//  Fourskie
//
//  Created by Pat Nakajima on 6/7/24.
//

import Foundation
import GRDB
import LibFourskie

extension Coordinate {
	func updateSQL(uuid: String, table: String) -> String {
		"""
		UPDATE \(table) SET coordinate = GeomFromText('POINT(\(latitude) \(longitude))', 4326) WHERE uuid = '\(uuid)'
		"""
	}
}

// Just a lil common interface around GRDB wrappers
protocol Model: Sendable, TableRecord, FetchableRecord, PersistableRecord {
	var uuid: String { get }

	static var tableName: String { get }
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
