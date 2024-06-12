//
//  Place+Database.swift
//  WhereWhen
//
//  Created by Pat Nakajima on 6/7/24.
//

import Foundation
import GRDB
import LibWhereWhen

extension HasManyAssociation: @unchecked Sendable {}

extension Place: DeleteSyncable {}

extension Place {
	static let checkinsAssociation = hasMany(Checkin.self, using: ForeignKey(["placeID"]))
}

extension Place: SpatialModel {
	public static var tableName: String { "place" }

	public static func create(in db: Database) throws {
		try db.create(table: tableName, options: [.ifNotExists]) { t in
			t.primaryKey("uuid", .text)
			t.column("addedAt", .date).notNull()

			// Coordinate
			t.column("latitude", .double).notNull()
			t.column("longitude", .double).notNull()
			t.column("name", .text).notNull()
			t.column("category", .text)

			t.column("isIgnored", .boolean).notNull().defaults(to: false)

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

			t.uniqueKey(["latitude", "longitude"])
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
			postalCode: row["postalCode"],

			isIgnored: row["isIgnored"]
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

		container["isIgnored"] = isIgnored
	}

	public static func sameCoordinates(as place: Place) -> QueryInterfaceRequest<Place> {
		Place.filter(sql: "latitude = ? AND longitude = ?", arguments: [
			place.coordinate.latitude,
			place.coordinate.longitude,
		])
	}
}
