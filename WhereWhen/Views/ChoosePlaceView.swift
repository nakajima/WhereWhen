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

struct ChoosePlaceView: View {
	// What part of the map are we lookin at
	@State private var region: MKCoordinateRegion

	// What are our possible results
	@State var possibleResults: [Place] = []

	// What places should be shown on the map
	@State private var visiblePlaces: [Place] = []

	// Is the user searching for something?
	@State private var searchTerm: String = ""

	@Environment(\.database) var database
	@Environment(\.navigationPath) var navigationPath
	@EnvironmentObject var coordinator: WhereWhenCoordinator

	let location: Coordinate
	let destination: (Place) -> Route

	init(location: Coordinate, destination: @escaping (Place) -> Route) {
		self.location = location
		self.destination = destination

		self._region = State(
			wrappedValue: .init(
				center: location.clLocation,
				span: .within(meters: 100)
			)
		)
	}

	var body: some View {
		VStack(spacing: 0) {
			PlaceListView(places: possibleResults, regionID: region.id) { visiblePlaces in
				self.visiblePlaces = visiblePlaces
			} cellBuilder: { place in
				NavigationLink(
					value: destination(place)
				) {
					ManualCheckinPlaceCellView(
						currentLocation: location,
						place: place
					)
					.contentShape(Rectangle())
				}
			}
			.transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .trailing)))
			.ignoresSafeArea(edges: .bottom)
			.searchable(text: $searchTerm, placement: .navigationBarDrawer(displayMode: .always))
			.safeAreaInset(edge: .top, spacing: 0) {
				Map(initialPosition: .region(region), interactionModes: [.pan, .zoom]) {
					ForEach(visiblePlaces) { place in
						Marker(place.name, coordinate: place.coordinate.clLocation)
					}

					Marker(coordinate: location.clLocation) {
						Label("You’re Here", systemImage: "person.fill")
					}
					.tint(Color.accentColor)
				}
				.onMapCameraChange { context in
					self.region = context.region
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
			.task(id: region.id) {
				await refresh()
			}
		}
	}

	func refresh() async {
		do {
			try? await Task.sleep(for: .seconds(0.3))
			if Task.isCancelled {
				return
			}

			let placeFinder = PlaceFinder(
				database: database,
				coordinate: .init(region.center),
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
