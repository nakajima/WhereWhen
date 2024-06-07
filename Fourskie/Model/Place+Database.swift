//
//  Place+Database.swift
//  Fourskie
//
//  Created by Pat Nakajima on 6/7/24.
//

import Foundation
import GRDB
import LibFourskie

extension HasManyAssociation: @unchecked Sendable {}

extension Place {
	static let checkinsAssociation = hasMany(Checkin.self, using: ForeignKey(["placeID"]))
}

extension Place: Model {
	static func create(in database: Database) throws {
		try database.create(table: "place") { t in
			t.primaryKey("uuid", .text)
			t.column("addedAt", .date).notNull()

			// Coordinate
			t.column("latitude", .double).notNull()
			t.column("longitude", .double).notNull()
			t.column("name", .text).notNull()
			t.column("category", .text)

			// Contact
			t.column("phoneNumber", .text)
			t.column("url", .text)

			// Address
			t.column("thoroughfare", .text)
			t.column("subThoroughfare", .text)
			t.column("locality", .text)
			t.column("subLocality", .text)
			t.column("administrativeArea", .text)
			t.column("subAdministrativeArea", .text)
			t.column("postalCode", .text)
		}
	}

	public init(row: Row) throws {
		self.init(
			uuid: row["uuid"],
			addedAt: row["addedAt"],
			coordinate: .init(latitude: row["latitude"], longitude: row["longitude"]),
			name: row["name"],
			phoneNumber: row["phoneNumber"],
			url: URL(string: row["url"] ?? ""),
			category: PlaceCategory(rawValue: row["category"] ?? ""),

			// Address
			thoroughfare: row["thoroughfare"],
			subThoroughfare: row["subThoroughfare"],
			locality: row["locality"],
			subLocality: row["subLocality"],
			administrativeArea: row["administrativeArea"],
			subAdministrativeArea: row["subAdministrativeArea"],
			postalCode: row["postalCode"]
		)
	}

	public func encode(to container: inout PersistenceContainer) throws {
		container["uuid"] = uuid
		container["addedAt"] = addedAt
		container["latitude"] = coordinate.latitude
		container["longitude"] = coordinate.longitude

		container["name"] = name
		container["phoneNumber"] = phoneNumber
		container["url"] = url
		container["category"] = category

		container["thoroughfare"] = thoroughfare
		container["subThoroughfare"] = subThoroughfare
		container["locality"] = locality
		container["subLocality"] = subLocality
		container["administrativeArea"] = administrativeArea
		container["subAdministrativeArea"] = subAdministrativeArea
		container["postalCode"] = postalCode
	}
}