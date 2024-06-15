//
//  Nominatim.swift
//  WhereWhen
//
//  Created by Pat Nakajima on 6/9/24.
//

import Database
import Foundation
import LibWhereWhen

public extension PlaceResolver {
	struct Nominatim: Resolver, Sendable {
		public let context: Context

		public init(context: Context) {
			self.context = context
		}

		public func suggestions() async throws -> [Suggestion] {
			let url = URL(string: "https://nominatim.openstreetmap.org/reverse")!.appending(
				queryItems: [
					.init(name: "lat", value: "\(context.coordinate.latitude)"),
					.init(name: "lon", value: "\(context.coordinate.longitude)"),
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

			return features.compactMap { feature -> PlaceResolver.Suggestion? in
				guard let properties = feature.properties else {
					return nil
				}

				guard let name = properties.name?.presence ?? properties.displayName?.presence,
				      let coordinates = feature.geometry?.coordinates,
				      coordinates.count == 2
				else {
					return nil
				}

				// For some reason, the coordinate comes back sometimes as [longitude, latitude]?
				let foundCoordinate = [
					Coordinate(coordinates[0], coordinates[1]),
					Coordinate(coordinates[1], coordinates[0]),
				].min(by: {
					$0.distance(to: context.coordinate) < $1.distance(to: context.coordinate)
				})!

				let address = properties.address

				let place = Place(
					uuid: UUID().uuidString,
					attribution: "https://www.openstreetmap.org",
					addedAt: Date(),
					coordinate: foundCoordinate,
					name: name,
					phoneNumber: nil,
					url: nil,
					category: PlaceCategory(rawValue: properties.category ?? ""),
					thoroughfare: address?["road"] ?? address?["highway"],
					subThoroughfare: address?["house_number"],
					locality: address?["city"],
					subLocality: address?["neighborhood"],
					administrativeArea: address?["state"],
					subAdministrativeArea: address?["county"],
					postalCode: address?["postcode"],
					isIgnored: false
				)

				// These don't tend to be what we're looking for but i guess
				// they're better than nothing.
				return .init(source: "Nominatim", place: place, confidence: -1, context: context)
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
