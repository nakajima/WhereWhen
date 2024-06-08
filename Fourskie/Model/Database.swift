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

final class Database: Sendable {
	let queue: DatabaseQueue

	static func create(name: String) -> Database {
		let path = URL.documentsDirectory.appending(path: name).path

		let needsCreating = !FileManager.default.fileExists(atPath: path)

		let queue = try! DatabaseQueue(path: path)

		print("DB: \(path)")
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
		try queue.write { db in
			try db.create(table: table, options: [.ifNotExists], body: definition)

			if spatial {
				spatialite_initialize()
				spatialite_alloc_connection()
				var spconnect: OpaquePointer?
				spatialite_init_ex(db.sqliteConnection, &spconnect, 1)

				try db.execute(literal: "SELECT InitSpatialMetaData('WGS84');")
				// Add POINT geometry field & create a spatial index for it. 4326 is the SRID
				// for lat/lng: https://spatialreference.org/ref/epsg/4326/
				let sqlSpatial = [
					"SELECT AddGeometryColumn('\(table)', 'geom', 4326, 'POINT', 'XY');",
					"SELECT CreateSpatialIndex('\(table)', 'geom');",
				]
				for sql in sqlSpatial {
					try db.execute(sql: sql)
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
