//
//  ManualCheckinChoosePlaceView.swift
//  Fourskie
//
//  Created by Pat Nakajima on 6/5/24.
//

import CoreLocation
import Foundation
import LibFourskie
import MapKit
import SwiftData
import SwiftUI

struct ManualCheckinChoosePlaceView: View {
	// What part of the map are we lookin at
	@State private var region: MKCoordinateRegion

	// What are our possible results
	@State var possibleResults: [Place] = []
	@State private var locationResults: [Place] = [] {
		didSet { findPossibleResults() }
	}
	@State private var searchResults: [Place] = [] {
		didSet { findPossibleResults() }
	}

	// What places should be shown on the map
	@State private var visiblePlaces: [Place] = []

	// Is the user searching for something?
	@State private var searchTerm: String = ""

	@Environment(\.modelContext) var modelContext
	@EnvironmentObject var coordinator: FourskieCoordinator

	let location: CLLocation

	init(location: CLLocation) {
		self.location = location

		self._region = State(
			wrappedValue: .init(
				center: location.coordinate,
				span: .within(meters: 500)
			)
		)
	}

	// This is gonna be slow. We should figure out a way to move
	// more of this logic into the DB.
	func findPossibleResults() {
		let places = (locationResults + searchResults).filter {
			if $0.coordinate.distance(to: .init(region.center)) > 1000 {
				return false
			}

			guard let search = searchTerm.presence else {
				return true
			}

			return $0.name.contains(search.trimmed)
		}

		let possibleResults = Set(places).sorted(by: {
			$0.coordinate.distance(to: .init(region.center)) <
				$1.coordinate.distance(to: .init(region.center))
		}).first(20)

		withAnimation {
			self.possibleResults = possibleResults
		}
	}

	var body: some View {
		VStack(spacing: 0) {
			PlaceListView(places: possibleResults, visiblePlaces: $visiblePlaces) { place in
				NavigationLink(
					destination: ManualCheckinFinishView(
						place: place,
						currentLocation: .init(location.coordinate)
					)
				) {
					ManualCheckinPlaceCellView(
						currentLocation: .init(location.coordinate),
						place: place
					)
				}
			}
			.searchable(text: $searchTerm)
			.safeAreaInset(edge: .top, spacing: 0) {
				Map(initialPosition: .region(region), interactionModes: [.pan, .zoom]) {
					ForEach(visiblePlaces) { place in
						Marker(place.name, coordinate: place.coordinate.clLocation)
					}
				}
				.onMapCameraChange { context in
					self.region = context.region
				}
				.frame(height: 200)
				.background(
					Color.primary.shadow(radius: 2)
				)
			}
			.task(id: searchTerm) {
				await refresh { finder in
					try await finder.search(searchTerm)
				}
			}
			.task(id: region.id) {
				await refresh { finder in
					try await finder.results(in: region)
				}
			}
		}
	}

	func refresh(block: (PlaceFinder) async throws -> [Place]) async {
		do {
			try? await Task.sleep(for: .seconds(0.3))
			if Task.isCancelled {
				return
			}

			let container = modelContext.container

			let placeFinder = PlaceFinder(
				container: container,
				coordinate: .init(region.center)
			)
			let searchResults = try await block(placeFinder)

			withAnimation {
				self.searchResults = searchResults
			}

			findPossibleResults()
		} catch {
			coordinator.errorMessage = error.localizedDescription
		}
	}
}

#if DEBUG
#Preview {
	ManualCheckinView()
		.environment(LocationListener(container: ModelContainer.preview))
		.modelContainer(ModelContainer.preview)
}
#endif
