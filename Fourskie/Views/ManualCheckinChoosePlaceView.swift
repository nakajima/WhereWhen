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
	@State private var isLoaded = false
	@State private var isSearching = false

	@State private var region: MKCoordinateRegion

	@State private var locationResults: [Place] = [] {
		didSet {
			findPossibleResults()
		}
	}

	@State private var visiblePlaces: [Place] = []

	@State var possibleResults: [Place] = []

	@State private var searchResults: [Place] = [] {
		didSet {
			findPossibleResults()
		}
	}

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
					print("camera changed")
					self.region = context.region
				}
				.frame(height: 200)
				.background(
					Color.primary.shadow(radius: 2)
				)
			}
			.task(id: searchTerm) {
				do {
					try? await Task.sleep(for: .seconds(0.3))
					if Task.isCancelled {
						print("Task is canceled, bail")
						return
					}

					let container = modelContext.container

					isSearching = true
					let searchResults = try await PlaceFinder(
						container: container,
						coordinate: .init(region.center)
					).search(searchTerm)

					withAnimation {
						self.searchResults = searchResults
						self.isSearching = false
					}

					findPossibleResults()
				} catch {
					coordinator.errorMessage = error.localizedDescription
					isSearching = false
				}
			}
			.task(id: region.id) {
				print("map changed")

				do {
					try? await Task.sleep(for: .seconds(0.5))
					if Task.isCancelled {
						print("Task is canceled, bail")
						return
					}

					let container = modelContext.container

					let possibleResults = try await PlaceFinder(
						container: container,
						coordinate: .init(region.center)
					).results(in: region)

					withAnimation {
						self.locationResults = possibleResults
						self.isLoaded = false
					}

					findPossibleResults()
				} catch {
					coordinator.errorMessage = error.localizedDescription
				}
			}
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
