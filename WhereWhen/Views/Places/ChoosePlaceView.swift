//
//  ChoosePlaceView.swift
//  WhereWhen
//
//  Created by Pat Nakajima on 6/5/24.
//

import CoreLocation
import Foundation
import LibWhereWhen
import MapKit
import SwiftUI

enum ChoosePlaceViewStatus {
	case loading, loaded(Place), loadingMore, loadedAll
}

struct ChoosePlaceView: View {
	// What part of the map are we lookin at
	@State private var region: MapCameraPosition

	// What are our possible results
	@State var possibleResults: [Place] = []

	// What places should be shown on the map
	@State private var visiblePlaces: [Place] = []

	// Is the user searching for something?
	@State private var searchTerm: String = ""

	@State private var distance = 100.0

	@Environment(\.database) var database
	@Environment(\.navigationPath) var navigationPath
	@Environment(\.coordinator) var coordinator

	let location: Coordinate
	let destination: (Place) -> Route

	init(location: Coordinate, destination: @escaping (Place) -> Route) {
		self.location = location
		self.destination = destination

		self._region = State(
			wrappedValue: .region(.init(
				center: location.clLocation,
				span: .within(meters: 100)
			))
		)
	}

	var body: some View {
		VStack(spacing: 0) {
			VStack {
				if !searchTerm.isBlank && possibleResults.isEmpty {
					CreatePlaceView(coordinate: location, checkin: nil, placeName: searchTerm.trimmed)
						.transition(.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .top)))
				} else {
					PlaceListView(places: possibleResults) { visiblePlaces in
						self.visiblePlaces = visiblePlaces
					} cellBuilder: { place in
						NavigationLink(
							value: destination(place)
						) {
							PlaceCellView(
								currentLocation: location,
								place: place
							)
							.contentShape(Rectangle())
						}
					} loadMore: {
						Button {
							Task {
								await loadMore()
							}
						} label: {
							Text("Load More")
						}
					}
					.transition(.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .top)))
					.ignoresSafeArea(edges: .bottom)
					.safeAreaInset(edge: .top, spacing: 0) {
						Map(position: $region, interactionModes: [.pan, .zoom]) {
							ForEach(visiblePlaces) { place in
								Marker(place.name, coordinate: place.coordinate.clLocation)
							}

							Marker(coordinate: location.clLocation) {
								Label("You’re Here", systemImage: "person.fill")
							}
							.tint(Color.accentColor)
						}
						.onMapCameraChange { context in
							self.region = .region(context.region)
						}
						.frame(height: 200)
						.background(
							Color.primary.shadow(radius: 2)
						)
					}
					.safeAreaInset(edge: .bottom) {
						Button("Create a Place") {
							print(navigationPath.wrappedValue)
							navigationPath.wrappedValue.append(.createPlace(location, nil))
						}
						.buttonStyle(.borderedProminent)
						.buttonBorderShape(.capsule)
					}
					.task(id: searchTerm) {
						await refresh()
					}
					.task(id: region.region?.id) {
						await refresh()
					}
				}
			}
			.searchable(text: $searchTerm, placement: .navigationBarDrawer(displayMode: .always))
		}
	}

	@MainActor func refresh() async {
		guard let region = region.region else {
			return
		}

		do {
			let placeFinder = PlaceFinder(
				database: database,
				coordinate: .init(region.center),
				distance: distance,
				search: searchTerm
			)

			let searchResults = try await placeFinder.results(in: region)

			withAnimation {
				// All of this is kinda gross
				self.possibleResults = searchResults
			}
		} catch {
			coordinator.errorMessage = error.localizedDescription
		}
	}

	@MainActor func loadMore() async {
		withAnimation {
			distance += 100
			self.region = .region(.init(
				center: location.clLocation,
				span: .within(meters: distance)
			))
		}

		guard let region = region.region else {
			return
		}

		do {
			let placeFinder = PlaceFinder(
				database: database,
				coordinate: .init(region.center),
				distance: distance,
				search: searchTerm
			)
			let searchResults = try await placeFinder.results(in: region)

			withAnimation {
				// All of this is kinda gross
				self.possibleResults = searchResults
			}
		} catch {
			coordinator.errorMessage = error.localizedDescription
		}
	}
}

#if DEBUG
	#Preview {
		PreviewsWrapper {
			ManualCheckinView()
		}
	}
#endif
