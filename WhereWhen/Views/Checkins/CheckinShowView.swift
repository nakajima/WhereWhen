//
//  CheckinShowView.swift
//  WhereWhen
//
//  Created by Pat Nakajima on 6/6/24.
//

import Foundation
import GRDBQuery
import LibWhereWhen
import MapKit
import SwiftUI

@MainActor struct CheckinShowView: View {
	@Environment(\.database) var database
	@Environment(\.navigationPath) var navigation
	@EnvironmentObject var coordinator: WhereWhenCoordinator

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
			VStack(alignment: .leading) {
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
					if let category = place.category?.description.presence {
						Divider()
						meta("Category") {
							Text(category)
						}
					}

					if let url = place.url {
						Divider()
						meta("Website") {
							Link(destination: url) {
								Text(url.absoluteString)
									.multilineTextAlignment(.leading)
									.font(.subheadline)
							}
						}
					}

					if let phoneNumber = place.phoneNumber?.presence {
						Divider()
						meta("Phone Number") {
							Link(phoneNumber, destination: URL(string: "tel:\(phoneNumber)")!)
						}
					}

					if !place.formatAddress().isBlank {
						Divider()
						meta("Address") {
							Text(place.formatAddress())
						}
					}
				}
			}

			Section(footer: Text("Ignoring a place will make WhereWhen try to avoid checking you in here automatically.")) {
				Button("Delete Checkin", role: .destructive) {
					isDeleting = true
				}
				.confirmationDialog("Delete this checkin?", isPresented: $isDeleting, titleVisibility: .visible) {
					Button("Delete", role: .destructive) {
						do {
							try database.delete(checkin)
							navigation.popToRoot()
						} catch {
							print("Error deleting checkin: \(error)")
						}
					}
					Button("Cancel", role: .cancel) {}
				}

				Button("Change Checkin…") {
					navigation.append(.checkinChoosePlace(checkin))
				}

				Button("Change Place…") {
					navigation.append(.updatePlace(place))
				}

				Button(place.isIgnored ? "Unignore Place" : "Ignore Place") {
					var place = place
					place.isIgnored.toggle()
					do {
						try place.save(to: database)
					} catch {
						coordinator.logger.error("Error saving place: \(place)")
					}
				}
			}
		}
		.safeAreaInset(edge: .top) {
			Map(initialPosition: .region(place.region(.within(meters: 100)))) {
				Marker(coordinate: place.coordinate.clLocation) {
					Text("You were here.")
				}
			}
			.frame(height: 200)
			.shadow(radius: 2)
		}
		.navigationTitle("Checkin Details")
		.navigationBarTitleDisplayMode(.inline)
	}

	func meta<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
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
