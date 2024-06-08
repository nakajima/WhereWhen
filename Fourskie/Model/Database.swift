//
//  Database.swift
//  Fourskie
//
//  Created by Pat Nakajima on 6/7/24.
//

import Foundation
import GRDB
import LibFourskie
import LibSpatialite

extension DatabaseQueue {
	// I try to set up the spatialite stuff in Configuration.prepareDatabase but
	// sometimes connections aren't getting it so it's just been safer to wrap
	// accesses of spatialite functions in this, even tho it's a bit of a perf hit.
	func spatialite<T>(_ operation: (GRDB.Database) throws -> T) throws -> T {
		try inDatabase { db in
			spatialite_initialize()
			spatialite_alloc_connection()
			var spconnect: OpaquePointer?
			spatialite_init_ex(db.sqliteConnection, &spconnect, 0)

			return try operation(db)
		}
	}
}

final class Database: Sendable {
	let queue: DatabaseQueue

	static func create(name: String) -> Database {
		let path = URL.documentsDirectory.appending(path: name).path

		var config = Configuration()

		// This isn't working reliably
		config.prepareDatabase { db in
			spatialite_initialize()
			spatialite_alloc_connection()
			var spconnect: OpaquePointer?
			spatialite_init_ex(db.sqliteConnection, &spconnect, 0)
			try db.execute(literal: "SELECT InitSpatialMetaData('WGS84');")
			let version = try String.fetchOne(db, sql: "SELECT spatialite_version()")
			print("spatialite setup for \(String(describing: db.sqliteConnection)): \(String(describing: version))")
		}

		#if DEBUG
		// Protect sensitive information by enabling verbose debugging in DEBUG builds only
		config.publicStatementArguments = true

		// It can be helpful to know where the db is
		print("DB: \(path)")
		#endif

		let queue = try! DatabaseQueue(path: path, configuration: config)
		return Database(queue: queue)
	}

	static let dev = create(name: "fourskiedev.sqlite")
	static let memory = Database(queue: try! DatabaseQueue())

	init(queue: DatabaseQueue) {
		self.queue = queue

		setupTables()
	}

	func setupTables() {
		try! Place.create(in: self)
		try! Checkin.create(in: self)
		try! DeletedRecord.create(in: self)
	}

	func create(table: String, spatial: Bool = false, definition: (TableDefinition) throws -> Void) throws {
		let existing = try! queue.read { db in
			try String.fetchAll(db, sql: """
			SELECT name FROM sqlite_master WHERE type='table'
			""")
		}

		if existing.contains(table) { return }

		try queue.write { db in
			try db.create(table: table, options: [.ifNotExists], body: definition)
		}

		if spatial {
			// Add POINT geometry field & create a spatial index for it. 4326 is the SRID
			// for lat/lng: https://spatialreference.org/ref/epsg/4326/
			let sqlSpatial = [
				"SELECT AddGeometryColumn('\(table)', 'coordinate', 4326, 'POINT', 'XY');",
				"SELECT CreateSpatialIndex('\(table)', 'coordinate');",
			]

			try queue.spatialite { db in
				for sql in sqlSpatial {
					try! db.execute(sql: sql)
				}
			}
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
