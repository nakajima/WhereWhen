//
//  ManualCheckinLocationView.swift
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
	@State private var possibleResults: [Place]?
	@State private var visiblePlaces: [Place] = []
	@Environment(\.modelContext) var modelContext

	let location: CLLocation

	var body: some View {
		VStack(spacing: 0) {
			if let possibleResults {
				PlaceListView(places: possibleResults, visiblePlaces: $visiblePlaces.animation(.snappy)) { place in
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
				.safeAreaInset(edge: .top, spacing: 0) {
					Map(initialPosition: .region(region)) {
						ForEach(visiblePlaces) { place in
							Marker(place.name, coordinate: place.coordinate.clLocation)
						}
					}
					.frame(height: 200)
					.background(
						Color.primary.shadow(radius: 2)
					)
				}

			} else {
				placeLoader
			}
		}
	}

	var region: MKCoordinateRegion {
		MKCoordinateRegion(
			center: location.coordinate,
			span: .within(meters: 1000)
		)
	}

	@MainActor var placeLoader: some View {
		HStack {
			Text("Looking for places…")
			Spacer()
			ProgressView()
				.task {
					do {
						let container = modelContext.container

						let possibleResults = try await PlaceNameFinder(
							container: container,
							coordinate: .init(location.coordinate)
						).results()

						withAnimation {
							self.possibleResults = possibleResults
						}
					} catch {
						print("Error looking for place names: \(error)")
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
