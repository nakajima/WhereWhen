//
//  PlaceFinder.swift
//  Fourskie
//
//  Created by Pat Nakajima on 6/5/24.
//

import Foundation
import LibFourskie
import MapKit

struct PlaceFinder {
	enum Error: Swift.Error {
		case noPlaceOrError
	}

	// We have a database so we can save found places
	let database: Database

	// Where is the user right now? This may differ from where they are searching
	let coordinate: Coordinate

	// A user entered string to search for
	let search: String

	init(database: Database, coordinate: Coordinate, search: String) {
		self.database = database
		self.coordinate = coordinate
		self.search = search
	}

	func results(in region: MKCoordinateRegion) async throws -> [Place] {
		// Looks up places we have in our DB
		let localResults = try localLookup()

		let remoteResults = if search.isBlank {
			// Looks up any places nearby from mapkit
			try await lookupFromCL(region: region)
		} else {
			// Looks up places matching the search term from mapkit
			try await lookupFromSearchTerm(term: search)
		}

		return Set(remoteResults + localResults)
			.filter {
				// Filter out far away stuff
				if $0.coordinate.distance(to: .init(region.center)) > 1000 {
					return false
				}

				// If the user searching, filter on that
				if let search = search.presence {
					return $0.name.lowercased().contains(search.lowercased())
				}

				// Otherwise let it all through
				return true
			}
			.sorted(by: {
				// Sort by how close the place is from our region's center (which may or
				// may not be where the user actually is)
				$0.coordinate.distance(to: .init(region.center)) <
					$1.coordinate.distance(to: .init(region.center))
			})
			.first(20)
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
