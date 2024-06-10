//
//  Checkin+Database.swift
//  WhereWhen
//
//  Created by Pat Nakajima on 6/7/24.
//

import Database
import Foundation
import GRDB
import LibWhereWhen

extension Checkin {
	static let placeAssociation = belongsTo(Place.self, using: ForeignKey(["placeID"]))
}

extension Checkin: DeleteSyncable {}

extension Checkin: Model, Sendable {
	public static var tableName: String { "checkin" }

	public static func create(in t: TableDefinition) throws {
		t.primaryKey("uuid", .text)
		t.column("source", .text).notNull()
		t.column("latitude", .double).notNull()
		t.column("longitude", .double).notNull()
		t.column("accuracy", .double).notNull()
		t.column("savedAt", .datetime).notNull()
		t.column("arrivalDate", .date)
		t.column("departureDate", .date)
		t.column("placeID", .text)
	}

	public init(row: Row) throws {
		self.init(
			source: row["source"],
			uuid: row["uuid"],
			coordinate: .init(latitude: row["latitude"], longitude: row["longitude"]),
			savedAt: row["savedAt"],
			accuracy: row["accuracy"],
			arrivalDate: row["arrivalDate"],
			departureDate: row["departureDate"],
			place: row["place"]
		)
	}

	public func encode(to container: inout PersistenceContainer) throws {
		container["source"] = source
		container["uuid"] = uuid
		container["latitude"] = coordinate.latitude
		container["longitude"] = coordinate.longitude
		container["savedAt"] = savedAt
		container["accuracy"] = accuracy
		container["arrivalDate"] = arrivalDate
		container["departureDate"] = departureDate
		container["placeID"] = place?.uuid
	}
}
