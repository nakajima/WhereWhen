//
//  ManualCheckinFinishView.swift
//  Fourskie
//
//  Created by Pat Nakajima on 6/5/24.
//

import LibFourskie
import MapKit
import SwiftUI

struct ManualCheckinFinishView: View {
	@EnvironmentObject var coordinator: FourskieCoordinator
	@Environment(\.dismiss) var dismiss
	@Environment(\.database) var database
	@Environment(\.navigationPath) var navigationPath

	var checkin: Checkin?
	var place: Place
	var currentLocation: Coordinate
	var caption: String = "Checking in here:"

	var body: some View {
		Form {
			VStack(alignment: .leading, spacing: Styles.verticalSpacing) {
				Text(caption)
					.font(.caption)
					.foregroundStyle(.secondary)
				Text(place.name)
					.font(.title2)
					.bold()
				Text(place.formatAddress())
					.font(.subheadline)
			}

			Section {
				Button(checkin == nil ? "Finish Checking In" : "Update Check In") {
					if var checkin {
						checkin.place = place

						do {
							try checkin.save(to: database)
						} catch {
							coordinator.errorMessage = error.localizedDescription
						}

						navigationPath.wrappedValue.removeAll()
					} else {
						coordinator.manualCheckIn(place: place, from: currentLocation)
					}
				}
				Button("Cancel", role: .cancel) {
					dismiss()
				}
				.foregroundStyle(.secondary)
			}
		}
		.navigationTitle("Finish Checking In")
		.navigationBarTitleDisplayMode(.inline)
		.safeAreaInset(edge: .top) {
			Map(initialPosition: .region(place.region(.within(meters: 100))), interactionModes: []) {
				Marker(place.name, coordinate: place.coordinate.clLocation)
			}
			.frame(height: 200)
			.mapControlVisibility(.hidden)
			.shadow(radius: 2)
		}
	}
}

#if DEBUG
	#Preview {
		NavigationStack {
			ManualCheckinFinishView(place: Place.preview, currentLocation: Place.preview.coordinate)
		}
	}
#endif
