//
//  PlaceNameFinder.swift
//  Fourskie
//
//  Created by Pat Nakajima on 6/5/24.
//

import Foundation
import LibFourskie
import MapKit
import SwiftData

struct PlaceNameFinder {
	enum Error: Swift.Error {
		case noPlaceOrError
	}

	let container: ModelContainer
	let coordinate: Coordinate

	init(container: ModelContainer, coordinate: Coordinate) {
		self.container = container
		self.coordinate = coordinate
	}

	func results() async throws -> [Place] {
		let localResults = try localLookup()
		let clResults = try await lookupFromCL()

		return Set(localResults + clResults).sorted(by: { $0.coordinate.distance(to: coordinate) < $1.coordinate.distance(to: coordinate) })
	}

	// TODO: This just returns EVERYTHING.
	func localLookup() throws -> [Place] {
		let context = ModelContext(container)
		let descriptor = FetchDescriptor<LocalPlace>()
		let localPlaces = try context.fetch(descriptor)
		return localPlaces.map { $0.wrapped }
	}

	func lookupFromCL() async throws -> [Place] {
		let request = MKLocalPointsOfInterestRequest(center: coordinate.clLocation, radius: 500)
		let search = MKLocalSearch(request: request)

		let cacheURL = URL.cachesDirectory.appending(path: coordinate.id)
		if FileManager.default.fileExists(atPath: cacheURL.path),
		   let cachedData = try? Data(contentsOf: cacheURL),
		   let cachedResults = try? JSONDecoder().decode([Place].self, from: cachedData)
		{
			print("Returning cached results")
			return cachedResults
		}

		return try await withCheckedThrowingContinuation { continuation in
			search.start { response, error in
				if let response, !response.mapItems.isEmpty {
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
