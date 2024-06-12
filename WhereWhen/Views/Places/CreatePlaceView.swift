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
	@EnvironmentObject var coordinator: WhereWhenCoordinator

	@State private var name: String = ""
	@State private var category: String = ""

	var body: some View {
		Form {
			TextField("Place Name", text: $name)

			Picker(selection: $category) {
				ForEach(PlaceCategory.allCases, id: \.rawValue) { category in
					Text("None")
						.tag("")
					Text(category.description)
						.tag(category.description)
				}
			} label: {
				Text("Category \(Text("(optional)").foregroundStyle(.secondary))")
			}

			Section {
				Button("Create Place") {
					let place = Place(
						uuid: UUID().uuidString,
						addedAt: Date(),
						coordinate: coordinate,
						name: name,
						phoneNumber: nil,
						url: nil,
						category: PlaceCategory(rawValue: category),
						thoroughfare: nil,
						subThoroughfare: nil,
						locality: nil,
						subLocality: nil,
						administrativeArea: nil,
						subAdministrativeArea: nil,
						postalCode: nil,
						isIgnored: false
					)

					do {
						try place.save(to: database)

						let destination: Route = if let checkin {
							.checkin(checkin, place)
						} else {
							.finishCheckinView(place, coordinate)
						}

						navigationPath.wrappedValue.append(destination)
					} catch {
						coordinator.errorMessage = error.localizedDescription
					}
				}
				.disabled(name.isBlank)
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
