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
	let distance = 250.0

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
					span: .within(meters: distance)
				)
			)
		)
	}

	var body: some View {
		PlaceFormView(place: $place, buttonLabel: "Update Place") {
			do {
				try place.save(to: database)
				navigation.popToRoot()
			} catch {
				logger.error("Error updating place: \(error)")
			}
		}
		.navigationTitle("Edit Place")
		.navigationBarTitleDisplayMode(.inline)
		.onChange(of: place.name) {
			print("Place name now \(place.name)")
		}
		.safeAreaInset(edge: .top) {
			Map(
				position: $position.animation()
			)
			.onMapCameraChange(frequency: .onEnd) { context in
				if position.positionedByUser {
					withAnimation {
						place.coordinate = .init(context.region.center)
					}
				}
			}
			.shadow(radius: 2)
			.overlay {
				Image(systemName: "mappin.and.ellipse")
					.foregroundStyle(.red)
					.shadow(radius: 2)
			}
			.frame(height: Styles.topInsetMapHeight)
			.onChange(of: place.coordinate) {
				self.position = .region(
					.init(
						center: place.coordinate.clLocation,
						span: .within(meters: distance)
					)
				)
			}
		}
	}
}

#if DEBUG
	#Preview {
		PreviewsWrapper {
			PlaceEditView(place: Place.preview)
		}
	}
#endif
