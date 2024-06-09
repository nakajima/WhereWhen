//
//  SpatialModel.swift
//  WhereWhen
//
//  Created by Pat Nakajima on 6/8/24.
//

import Foundation
import LibWhereWhen

protocol SpatialModel: Model, Sendable {
	var coordinate: Coordinate { get }
}

extension SpatialModel {
	func syncCoordinate(in database: Database) throws {
		try database.queue.spatialite { db in
			let version = try String.fetchOne(db, sql: "SELECT spatialite_version()")
			print("syncCoordinate for \(db.sqliteConnection): \(version)")

			try db.execute(sql: coordinate.updateSQL(uuid: uuid, table: Self.tableName))
		}
	}
}
