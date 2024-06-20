//
//  PlaceView.swift
//  WhereWhen
//
//  Created by Pat Nakajima on 6/20/24.
//

import SwiftUI

import Database
import GRDBQuery
import LibWhereWhen
import MapKit
import SwiftUI

struct PlaceView: View {
	var place: Place

	@Query(PlaceCheckinsRequest(placeUUID: "")) var checkins: [Checkin]

	init(place: Place) {
		self.place = place
		self._checkins = Query(PlaceCheckinsRequest(placeUUID: place.uuid))
	}

	var body: some View {
		List {
			Section("Checkins Here (\(checkins.count))") {
				ForEach(checkins) { checkin in
					CheckinCellView(checkin: checkin)
				}
			}
		}
		.toolbar {
			ToolbarItem {
				NavigationLink(value: Route.updatePlace(place)) {
					Text("Edit")
				}
			}
		}
		.safeAreaInset(edge: .top) {
			Map(initialPosition: .region(place.region(.within(meters: 200)))) {
				Marker(coordinate: place.coordinate.clLocation) {
					Text(place.name)
				}
			}
			.frame(maxHeight: 200)
			.shadow(radius: 2)
		}
		.navigationTitle(place.name)
	}
}

#if DEBUG
	struct PlaceViewPreviewContainer: View {
		@State var place: Place

		var body: some View {
			PlaceView(place: place)
				.onAppear {
					try! place.save(to: .memory)
					try! Checkin.makePreview(block: {
						$0[\.savedAt] = Date()
						$0.place = place
					}).save(to: .memory)
				}
		}
	}

	#Preview {
		PreviewsWrapper {
			PlaceViewPreviewContainer(place: Place.preview)
		}
	}
#endif
