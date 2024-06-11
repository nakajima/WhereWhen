import Foundation

// MARK: - OverpassResponse

public struct OverpassResponse: Codable, Sendable {
	public let version: Double?
	public let generator: String?
	public let osm3S: Osm3S?
	public let elements: [Element]?

	public enum CodingKeys: String, CodingKey {
		case version, generator
		case osm3S = "osm3s"
		case elements
	}

	public init(version: Double?, generator: String?, osm3S: Osm3S?, elements: [Element]?) {
		self.version = version
		self.generator = generator
		self.osm3S = osm3S
		self.elements = elements
	}
}

// MARK: - Element

public struct Element: Codable, Sendable {
	public let type: String?
	public let id: Int?
	public let nodes: [Int]?
	public let tags: [String: String]?
	public let lat, lon: Double?

	public init(type: String?, id: Int?, nodes: [Int]?, tags: [String: String]?, lat: Double?, lon: Double?) {
		self.type = type
		self.id = id
		self.nodes = nodes
		self.tags = tags
		self.lat = lat
		self.lon = lon
	}
}

// MARK: - Osm3S

public struct Osm3S: Codable, Sendable {
	public let timestampOsmBase: Date?
	public let copyright: String?

	public enum CodingKeys: String, CodingKey {
		case timestampOsmBase = "timestamp_osm_base"
		case copyright
	}

	public init(timestampOsmBase: Date?, copyright: String?) {
		self.timestampOsmBase = timestampOsmBase
		self.copyright = copyright
	}
}
