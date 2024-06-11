//
//  CheckinCellView.swift
//  WhereWhen
//
//  Created by Pat Nakajima on 6/5/24.
//

import Database
import LibWhereWhen
import MapKit
import SwiftUI

struct CheckinCellMapView: View {
	let region: MKCoordinateRegion

	var body: some View {
		Map(initialPosition: .region(region), interactionModes: [])
			.frame(width: 64, height: 64)
			.clipShape(RoundedRectangle(cornerRadius: 8))
			.padding(8)
			.overlay {
				Image(systemName: "mappin")
					.foregroundStyle(Color.accentColor)
			}
	}
}

struct CheckinWithPlaceCellView: View {
	@Environment(\.database) var database

	let checkin: Checkin
	let place: Place

	var body: some View {
		HStack {
			CheckinCellMapView(region: place.region(.within(meters: 500)))

			VStack(alignment: .leading) {
				Text(place.name)
					.bold()
					.frame(maxWidth: .infinity, alignment: .leading)
				Text(checkin.savedAt.formatted(.relative(presentation: .named)))
					.font(.subheadline)
					.foregroundStyle(.secondary)
			}
		}
		.listRowInsets(.init())
		.swipeActions {
			Button("Remove Place") {
				var checkin = checkin
				checkin.place = nil
				try! checkin.save(to: database)
			}

			Button("Delete", role: .destructive) {
				try! database.delete(checkin)
			}
		}
	}
}

struct CheckinWithoutPlaceCellView: View {
	@Environment(\.database) var database
	let checkin: Checkin

	var body: some View {
		HStack {
			CheckinCellMapView(region: checkin.region(.within(meters: 500)))

			VStack(alignment: .leading) {
				Text("Unknown Place")
					.bold()
					.foregroundStyle(.secondary)
					.frame(maxWidth: .infinity, alignment: .leading)
				Text(checkin.savedAt.formatted(.relative(presentation: .named)))
					.font(.subheadline)
					.foregroundStyle(.secondary)
			}
		}
		.swipeActions {
			Button("Delete", role: .destructive) {
				try! database.delete(checkin)
			}
		}
	}
}

struct CheckinCellView: View {
	let checkin: Checkin

	var body: some View {
		Group {
			if let place = checkin.place {
				NavigationLink(value: Route.checkin(checkin, place)) {
					CheckinWithPlaceCellView(checkin: checkin, place: place)
				}
			} else {
				NavigationLink(value: Route.checkinChoosePlace(checkin)) {
					CheckinWithoutPlaceCellView(checkin: checkin)
				}
			}
		}
		// padding is handled by the cell view
		.listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 12))
	}
}

#if DEBUG
	#Preview {
		PreviewsWrapper {
			List {
				CheckinListView()
			}
			.onAppear {
				try! Checkin.preview.save(to: .memory)
			}
		}
	}
#endif
