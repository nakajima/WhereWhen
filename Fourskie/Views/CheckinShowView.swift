//
//  CheckinShowView.swift
//  Fourskie
//
//  Created by Pat Nakajima on 6/6/24.
//

import Foundation
import LibFourskie
import MapKit
import SwiftData
import SwiftUI

@MainActor struct CheckinShowView: View {
	let checkin: LocalCheckin
	let place: LocalPlace

	@State private var isDeleting = false

	var body: some View {
		List {
			VStack(alignment: .leading, spacing: Styles.verticalSpacing) {
				VStack(alignment: .leading, spacing: Styles.verticalSpacing) {
					Text(place.name)
						.bold()
					Text("You’ve checked-in here \(place.checkins.count.ordinalize("time")).")
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
					Text(place.wrapped.formatAddress())
				}
			}

			Section {
				Button("Delete Checkin", role: .destructive) {
					isDeleting = true
				}
				.confirmationDialog("Delete this checkin?", isPresented: $isDeleting, titleVisibility: .visible) {
					Button("Delete", role: .destructive) {}
					Button("Cancel", role: .cancel) {}
				}
			}
		}
		.safeAreaInset(edge: .top) {
			Map(initialPosition: .region(place.wrapped.region(.within(meters: 100))), interactionModes: []) {
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
				checkin: LocalCheckin.model(
					for: Checkin.preview,
					in: ModelContainer.preview.mainContext
				),
				place: LocalPlace.model(
					for: Place.preview,
					in: ModelContainer.preview.mainContext
				)
			)
			.onAppear {
				let checkin = LocalCheckin.model(
					for: Checkin.preview,
					in: ModelContainer.preview.mainContext
				)

				let place = LocalPlace.model(
					for: Place.preview,
					in: ModelContainer.preview.mainContext
				)

				checkin.place = place
			}
		}
	}
#endif
