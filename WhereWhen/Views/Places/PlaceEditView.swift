//
//  PlaceEditView.swift
//  WhereWhen
//
//  Created by Pat Nakajima on 6/14/24.
//

import LibWhereWhen
import MapKit
import SwiftUI

private let logger = DiskLogger(label: "PlaceEditView", location: URL.documentsDirectory.appending(path: "wherewhen.log"))

struct PlaceEditView: View {
	@Environment(\.database) var database
	@Environment(\.navigationPath) var navigation

	@State var place: Place
	@State private var position: MapCameraPosition

	init(place: Place) {
		self._place = State(wrappedValue: place)
		self._position = State(
			wrappedValue: .region(
				.init(
					center: place.coordinate.clLocation,
					span: .within(meters: 100)
				)
			)
		)
	}

	var body: some View {
		Form {
			PlaceFormView(place: $place, buttonLabel: "Update Place") {
				do {
					try place.save(to: database)
					navigation.popToRoot()
				} catch {
					logger.error("Error updating place: \(error)")
				}
			}
		}
		.onChange(of: place.name) {
			print("Place name now \(place.name)")
		}
		.safeAreaInset(edge: .top) {
			Map(
				position: $position
			)
			.onMapCameraChange(frequency: .onEnd) { context in
				place.coordinate = .init(context.region.center)
			}
			.overlay {
				Image(systemName: "mappin.and.ellipse")
					.foregroundStyle(.red)
					.shadow(radius: 2)
			}
			.frame(height: 200)
			.onChange(of: place.coordinate) {
				self.position = .region(
					.init(
						center: place.coordinate.clLocation,
						span: .within(meters: 100)
					)
				)
			}
		}
	}
}

#if DEBUG
	#Preview {
		PlaceEditView(place: Place.preview)
	}
#endif
