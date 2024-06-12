//
//  PlaceFinder.swift
//  WhereWhen
//
//  Created by Pat Nakajima on 6/5/24.
//

import Database
import Foundation
import LibWhereWhen
import MapKit
import PlaceResolver

struct PlaceFinder {
	enum Error: Swift.Error {
		case noPlaceOrError
	}

	// We have a database so we can save found places
	let database: DatabaseContainer

	// Where is the user right now? This may differ from where they are searching
	let coordinate: Coordinate

	// A user entered string to search for
	let search: String

	init(database: DatabaseContainer, coordinate: Coordinate, search: String) {
		self.database = database
		self.coordinate = coordinate
		self.search = search
	}

	func results(in region: MKCoordinateRegion) async throws -> [Place] {
		let suggestions = await PlaceResolver(database: database, coordinate: .init(region.center))
			.suggestions()

		if let search = search.presence {
			return suggestions.compactMap { suggestion in
				if suggestion.place.name.lowercased().contains(search.lowercased()) {
					return suggestion.place
				} else {
					return nil
				}
			}
		} else {
			return suggestions.map(\.place)
		}
	}

	private func lookupFromSearchTerm(term: String) async throws -> [Place] {
		if term.isBlank {
			return []
		}

		let request = MKLocalSearch.Request()
		request.naturalLanguageQuery = term.trimmed
		let search = MKLocalSearch(request: request)

		return try await results(for: search)
	}

	// TODO: This just returns EVERYTHING.
	private func localLookup() throws -> [Place] {
		return try Place.all(in: database)
	}

	private func lookupFromCL(region: MKCoordinateRegion) async throws -> [Place] {
		let request = MKLocalPointsOfInterestRequest(coordinateRegion: region)
		let search = MKLocalSearch(request: request)

		if Task.isCancelled {
			return []
		}

		return try await results(for: search)
	}

	private func results(for search: MKLocalSearch) async throws -> [Place] {
		if Task.isCancelled { return [] }

		return try await withCheckedThrowingContinuation { continuation in
			search.start { response, error in
				if let response {
					var results: [Place] = []
					for item in response.mapItems {
						guard let name = item.name else {
							continue
						}

						let place = Place(
							uuid: UUID().uuidString,
							addedAt: Date(),
							coordinate: .init(item.placemark.coordinate),
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

					do {
						for place in results {
							try place.save(to: database)
						}
					} catch {
						continuation.resume(throwing: error)
						return
					}

					continuation.resume(returning: results)
					return
				}

				if let error {
					continuation.resume(throwing: error)
				} else {
					continuation.resume(throwing: Error.noPlaceOrError)
				}
			}
		}
	}
}
