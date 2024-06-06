//
//  PlaceFinder.swift
//  Fourskie
//
//  Created by Pat Nakajima on 6/5/24.
//

import Foundation
import LibFourskie
import MapKit
import SwiftData

struct PlaceFinder {
	enum Error: Swift.Error {
		case noPlaceOrError
	}

	let container: ModelContainer
	let coordinate: Coordinate

	init(container: ModelContainer, coordinate: Coordinate) {
		self.container = container
		self.coordinate = coordinate
	}

	func search(_ term: String) async throws -> [Place] {
		if Task.isCancelled || term.isBlank {
			return []
		}

		let request = MKLocalSearch.Request()
		request.naturalLanguageQuery = term.trimmed
		let search = MKLocalSearch(request: request)

		return try await results(for: search)
	}

	func results(in region: MKCoordinateRegion) async throws -> [Place] {
		let localResults = try localLookup()
		let clResults = try await lookupFromCL(region: region)

		return Set(localResults + clResults).map { $0 }
	}

	// TODO: This just returns EVERYTHING.
	private func localLookup() throws -> [Place] {
		let context = ModelContext(container)
		let descriptor = FetchDescriptor<LocalPlace>()
		let localPlaces = try context.fetch(descriptor)
		return localPlaces.map { $0.wrapped }
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
							postalCode: item.placemark.postalCode
						)

						results.append(place)
					}

					let context = ModelContext(container)
					for place in results {
						let localPlace = LocalPlace(wrapped: place)
						context.insert(localPlace)
					}

					do {
						try context.save()
					} catch {
						print("Error saving places: \(error)")
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
