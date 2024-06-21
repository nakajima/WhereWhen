//
//  CreatePlaceView.swift
//  WhereWhen
//
//  Created by Pat Nakajima on 6/8/24.
//

import Foundation
import LibWhereWhen
import MapKit
import SwiftUI

struct CreatePlaceView: View {
	var coordinate: Coordinate

	// If we're creating this place for a checkin, the checkin will be here.
	var checkin: Checkin?

	@Environment(\.database) var database
	@Environment(\.dismiss) var dismiss
	@Environment(\.navigationPath) var navigationPath
	@Environment(\.coordinator) var coordinator

	@State var placeToCreate: Place

	init(coordinate: Coordinate, checkin: Checkin? = nil) {
		self.coordinate = coordinate
		self.checkin = checkin

		self._placeToCreate = State(wrappedValue: Place(
			uuid: UUID().uuidString,
			attribution: "Manually Entered",
			addedAt: Date(),
			coordinate: coordinate,
			name: "",
			phoneNumber: nil,
			url: nil,
			category: .none,
			thoroughfare: nil,
			subThoroughfare: nil,
			locality: nil,
			subLocality: nil,
			administrativeArea: nil,
			subAdministrativeArea: nil,
			postalCode: nil,
			isIgnored: false
		))
	}

	var body: some View {
		PlaceFormView(place: $placeToCreate, buttonLabel: "Create Place") {
			do {
				try placeToCreate.save(to: database)

				let destination: Route = if let checkin {
					.checkin(checkin, placeToCreate)
				} else {
					.finishCheckinView(placeToCreate, coordinate)
				}

				navigationPath.wrappedValue.append(destination)
			} catch {
				coordinator.errorMessage = error.localizedDescription
			}
		}
		.safeAreaInset(edge: .top, spacing: 0) {
			Map(
				initialPosition: .region(
					.init(
						center: coordinate.clLocation,
						span: .within(meters: 50)
					)
				),
				interactionModes: [.zoom]
			) {
				Marker(coordinate: coordinate.clLocation) {
					Label("Create This Place", systemImage: "mappin")
				}
				.tint(Color.accentColor)
			}
			.frame(height: 200)
			.background(
				Color.primary.shadow(radius: 2)
			)
		}
		.transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .trailing)))
		.navigationTitle("Create a Place")
		.navigationBarTitleDisplayMode(.inline)
	}
}

#if DEBUG
	#Preview {
		PreviewsWrapper {
			CreatePlaceView(
				coordinate: .init(
					latitude: 34.13608241796701,
					longitude: -118.1895474362531
				)
			)
		}
	}
#endif
