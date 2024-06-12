//
//  Overpass.swift
//  WhereWhen
//
//  Created by Pat Nakajima on 6/9/24.
//

import Database
import Foundation
import LibWhereWhen

extension PlaceResolver {
	struct Overpass: Resolver {
		let coordinate: Coordinate

		init(database _: DatabaseContainer, coordinate: Coordinate) {
			self.coordinate = coordinate
		}

		func suggestions() async throws -> [Suggestion] {
			let url = URL(string: "https://overpass-api.de/api/interpreter")!.appending(
				queryItems: [
					.init(name: "lat", value: "\(coordinate.latitude)"),
					.init(name: "lon", value: "\(coordinate.longitude)"),
					.init(name: "format", value: "geojson"),
				]
			)

			var request = URLRequest(url: url)
			request.httpMethod = "POST"
			request.httpBody = Data(query.utf8)

			let data = try await URLSession.shared.data(for: request).0
			let decoder = JSONDecoder()
			decoder.dateDecodingStrategy = .iso8601
			let response = try decoder.decode(OverpassResponse.self, from: data)

			guard let elements = response.elements else {
				return []
			}

			return elements.compactMap { element in
				guard element.type == "way", let tags = element.tags, let name = tags["name"] else {
					return nil
				}

				let coordinate = findCenter(of: response.elements?.filter { $0.type == "node" }) ?? coordinate

				let place = Place(
					uuid: UUID().uuidString,
					addedAt: Date(),
					coordinate: coordinate,
					name: name,
					phoneNumber: tags["phone"] ?? tags["contact:phone"],
					url: URL(string: tags["website"] ?? ""),
					category: PlaceCategory(rawValue: tags["amenity"] ?? ""),
					thoroughfare: tags["addr:street"],
					subThoroughfare: tags["addr:housenumber"],
					locality: tags["Kettleman City"],
					subLocality: nil,
					administrativeArea: tags["addr:state"],
					subAdministrativeArea: nil,
					postalCode: tags["addr:postcode"],
					isIgnored: false
				)

				return .init(source: "Overpass", place: place, confidence: 10)
			}
		}

		func findCenter(of nodes: [Element]?) -> Coordinate? {
			guard let nodes, !nodes.isEmpty else { return nil }

			let latlngs = nodes.compactMap { node -> (lat: Double, lon: Double)? in
				guard let lat = node.lat, let lon = node.lon else {
					return nil
				}

				return (lat, lon)
			}

			let totalLatitude = latlngs.reduce(0.0) { $0 + $1.lat }
			let totalLongitude = latlngs.reduce(0.0) { $0 + $1.lon }

			let centroidLatitude = totalLatitude / Double(nodes.count)
			let centroidLongitude = totalLongitude / Double(nodes.count)

			return .init(centroidLatitude, centroidLongitude)
		}

		// Looks for buildings with a name that are within 50 meters of the coordinate
		var query: String {
			"""
			[out:json];
			(
			way["building"](around:50.0, \(coordinate.latitude), \(coordinate.longitude))["name"];
			);
			out body;
			>;
			out skel qt;
			"""
		}
	}
}
