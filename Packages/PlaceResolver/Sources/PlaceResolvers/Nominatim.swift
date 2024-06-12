//
//  Nominatim.swift
//  WhereWhen
//
//  Created by Pat Nakajima on 6/9/24.
//

import Database
import Foundation
import LibWhereWhen

extension PlaceResolver {
	struct Nominatim: Resolver {
		let coordinate: Coordinate

		init(database _: DatabaseContainer, coordinate: Coordinate) {
			self.coordinate = coordinate
		}

		func suggestions() async throws -> [Suggestion] {
			let url = URL(string: "https://nominatim.openstreetmap.org/reverse")!.appending(
				queryItems: [
					.init(name: "lat", value: "\(coordinate.latitude)"),
					.init(name: "lon", value: "\(coordinate.longitude)"),
					.init(name: "format", value: "geojson"),
				]
			)

			var request = URLRequest(url: url)
			request.addValue("WhereWhen v0.0.1", forHTTPHeaderField: "User-Agent")

			let (data, _) = try await URLSession.shared.data(for: request)

			guard let response = try? JSONDecoder().decode(NominatimResponse.self, from: data),
			      let features = response.features
			else {
				return []
			}

			return features.compactMap { feature in
				guard let properties = feature.properties else {
					return nil
				}

				guard let name = properties.displayName?.presence ?? properties.name?.presence,
				      let coordinates = feature.geometry?.coordinates,
				      coordinates.count == 2
				else {
					return nil
				}

				let place = Place(
					uuid: UUID().uuidString,
					attribution: "https://www.openstreetmap.org",
					addedAt: Date(),
					coordinate: .init(coordinates[0], coordinates[1]),
					name: name,
					phoneNumber: nil,
					url: nil,
					category: PlaceCategory(rawValue: properties.category ?? ""),
					thoroughfare: nil,
					subThoroughfare: nil,
					locality: nil,
					subLocality: nil,
					administrativeArea: nil,
					subAdministrativeArea: nil,
					postalCode: nil,
					isIgnored: false
				)

				// These don't tend to be what we're looking for but i guess
				// they're better than nothing.
				return .init(source: "Nominatim", place: place, confidence: -1)
			}
		}
	}
}

private extension String {
	var presence: String? {
		if trimmingCharacters(in: .whitespacesAndNewlines) == "" {
			return nil
		}

		return self
	}
}
