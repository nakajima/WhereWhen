//
//  CheckinShowView.swift
//  Fourskie
//
//  Created by Pat Nakajima on 6/6/24.
//

import Foundation
import GRDBQuery
import LibFourskie
import MapKit
import SwiftUI

@MainActor struct CheckinShowView: View {
	@Environment(\.database) var database
	@Query(PlaceCheckinsRequest(placeUUID: ""))
	var placeCheckins: [Checkin]

	let checkin: Checkin

	@LiveModel var place: Place

	@State private var isDeleting = false

	init(checkin: Checkin, place: Place) {
		self.checkin = checkin
		self._place = LiveModel(wrappedValue: place)
		self._placeCheckins = Query(PlaceCheckinsRequest(placeUUID: place.uuid))
	}

	var body: some View {
		List {
			VStack(alignment: .leading, spacing: Styles.verticalSpacing) {
				VStack(alignment: .leading, spacing: Styles.verticalSpacing) {
					Text(place.name)
						.bold()
					Text("You’ve checked-in here \(placeCheckins.count.ordinalize("time")).")
						.font(.subheadline)
						.foregroundStyle(.secondary)
				}
			}

			VStack(alignment: .leading, spacing: Styles.verticalSpacing) {
				if let category = place.category {
					meta("Category") {
						Text(category.description)
					}
				}

				if let url = place.url {
					Divider()
					meta("Website") {
						Link(destination: url) {
							Text(url.absoluteString)
								.multilineTextAlignment(.leading)
						}
					}
				}

				if let phoneNumber = place.phoneNumber {
					Divider()
					meta("Phone Number") {
						Link(phoneNumber, destination: URL(string: "tel:\(phoneNumber)")!)
					}
				}

				Divider()
				meta("Address") {
					Text(place.formatAddress())
				}
			}

			Section(footer: Text("Ignoring a place will make Fourskie try to avoid checking you in here automatically.")) {
				Button("Delete Checkin", role: .destructive) {
					isDeleting = true
				}
				.confirmationDialog("Delete this checkin?", isPresented: $isDeleting, titleVisibility: .visible) {
					Button("Delete", role: .destructive) {}
					Button("Cancel", role: .cancel) {}
				}

				Button(place.isIgnored ? "Unignore Place" : "Ignore Place") {
					var place = place
					place.isIgnored.toggle()
					try! place.save(to: database)
				}
			}
		}
		.safeAreaInset(edge: .top) {
			Map(initialPosition: .region(place.region(.within(meters: 100))), interactionModes: []) {
				Marker(coordinate: checkin.coordinate.clLocation) {}
			}
			.frame(height: 200)
			.shadow(radius: 2)
		}
		.navigationTitle("Checkin Details")
		.navigationBarTitleDisplayMode(.inline)
	}

	func meta<Content: View>(_ title: String, content: () -> Content) -> some View {
		VStack(alignment: .leading) {
			Text(title)
				.font(.caption)
				.foregroundStyle(.secondary)
			content()
				.font(.subheadline)
				.buttonStyle(.borderless)
		}
		.multilineTextAlignment(.leading)
	}
}

#if DEBUG
	#Preview {
		PreviewsWrapper {
			CheckinShowView(
				checkin: Checkin.preview,
				place: Place.preview
			)
		}
	}
#endif
