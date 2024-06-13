//
//  MapKit.swift
//  WhereWhen
//
//  Created by Pat Nakajima on 6/9/24.
//

import Database
import Foundation
import LibWhereWhen
import MapKit

// Copied from the main app because I wasn't sure where it should live.
extension MKCoordinateSpan {
	static func within(meters: Double) -> MKCoordinateSpan {
		MKCoordinateSpan(
			latitudeDelta: meters / 111_000.0,
			longitudeDelta: meters / 111_000.0
		)
	}
}

extension PlaceResolver {
	struct MapKit: Resolver {
		public let context: Context

		func suggestions() async throws -> [Suggestion] {
			let request = MKLocalPointsOfInterestRequest(
				center: .init(
					latitude: context.coordinate.latitude,
					longitude: context.coordinate.longitude
				),
				radius: 100
			)
			let search = MKLocalSearch(request: request)

			let places: [Place] = try await withCheckedThrowingContinuation { continuation in
				search.start { response, error in
					if let response {
						continuation.resume(returning: placesFrom(response: response))
					} else if let error {
						continuation.resume(throwing: error)
					} else {
						continuation.resume(returning: [])
					}
				}
			}

			// These tend to be p good
			return places.map {
				.init(source: "Apple", place: $0, confidence: 10, context: context)
			}
		}

		func placesFrom(response: MKLocalSearch.Response) -> [Place] {
			var results: [Place] = []
			for item in response.mapItems {
				guard let name = item.name else {
					continue
				}

				let place = Place(
					uuid: UUID().uuidString,
					attribution: "Apple",
					addedAt: Date(),
					coordinate: .init(
						latitude: item.placemark.coordinate.latitude,
						longitude: item.placemark.coordinate.longitude
					),
					name: name,
					phoneNumber: item.phoneNumber,
					url: item.url,
					category: item.pointOfInterestCategory?.wrapped,
					thoroughfare: item.placemark.thoroughfare,
					subThoroughfare: item.placemark.subThoroughfare,
					locality: item.placemark.locality,
					subLocality: item.placemark.subLocality,
					administrativeArea: item.placemark.administrativeArea,
					subAdministrativeArea: item.placemark.subAdministrativeArea,
					postalCode: item.placemark.postalCode,
					isIgnored: false
				)

				results.append(place)
			}

			return results
		}
	}
}
