// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let nominatimResponse = try? JSONDecoder().decode(NominatimResponse.self, from: jsonData)

import Foundation

// MARK: - NominatimResponse

public struct NominatimResponse: Codable, Sendable {
	public let type, licence: String?
	public let features: [Feature]?

	public init(type: String?, licence: String?, features: [Feature]?) {
		self.type = type
		self.licence = licence
		self.features = features
	}
}

// MARK: - Feature

public struct Feature: Codable, Sendable {
	public let type: String?
	public let properties: Properties?
	public let bbox: [Double]?
	public let geometry: Geometry?

	public init(type: String?, properties: Properties?, bbox: [Double]?, geometry: Geometry?) {
		self.type = type
		self.properties = properties
		self.bbox = bbox
		self.geometry = geometry
	}
}

// MARK: - Geometry

public struct Geometry: Codable, Sendable {
	public let type: String?
	public let coordinates: [Double]?

	public init(type: String?, coordinates: [Double]?) {
		self.type = type
		self.coordinates = coordinates
	}
}

// MARK: - Properties

public struct Properties: Codable, Sendable {
	public let placeID: Int?
	public let osmType: String?
	public let osmID, placeRank: Int?
	public let category, type: String?
	public let importance: Double?
	public let addresstype, name, displayName: String?
	public let address: Address?

	public enum CodingKeys: String, CodingKey {
		case placeID = "place_id"
		case osmType = "osm_type"
		case osmID = "osm_id"
		case placeRank = "place_rank"
		case category, type, importance, addresstype, name
		case displayName = "display_name"
		case address
	}

	public init(placeID: Int?, osmType: String?, osmID: Int?, placeRank: Int?, category: String?, type: String?, importance: Double?, addresstype: String?, name: String?, displayName: String?, address: Address?) {
		self.placeID = placeID
		self.osmType = osmType
		self.osmID = osmID
		self.placeRank = placeRank
		self.category = category
		self.type = type
		self.importance = importance
		self.addresstype = addresstype
		self.name = name
		self.displayName = displayName
		self.address = address
	}
}

// MARK: - Address

public struct Address: Codable, Sendable {
	public let highway, road, city, county: String?
	public let state, iso31662Lvl4, postcode, country: String?
	public let countryCode: String?

	public enum CodingKeys: String, CodingKey {
		case highway, road, city, county, state
		case iso31662Lvl4 = "ISO3166-2-lvl4"
		case postcode, country
		case countryCode = "country_code"
	}

	public init(highway: String?, road: String?, city: String?, county: String?, state: String?, iso31662Lvl4: String?, postcode: String?, country: String?, countryCode: String?) {
		self.highway = highway
		self.road = road
		self.city = city
		self.county = county
		self.state = state
		self.iso31662Lvl4 = iso31662Lvl4
		self.postcode = postcode
		self.country = country
		self.countryCode = countryCode
	}
}
