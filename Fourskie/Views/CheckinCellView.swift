//
//  CheckinCellView.swift
//  Fourskie
//
//  Created by Pat Nakajima on 6/5/24.
//

import LibFourskie
import MapKit
import SwiftData
import SwiftUI

struct CheckinCellMapView: View {
	let region: MKCoordinateRegion

	var body: some View {
		Map(initialPosition: .region(region))
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
	@Environment(\.modelContext) var modelContext

	let checkin: LocalCheckin
	let place: LocalPlace

	var body: some View {
		HStack {
			CheckinCellMapView(region: place.wrapped.region(.within(meters: 500)))

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
				checkin.place = nil
				try! modelContext.save()
			}
			Button("Delete", role: .destructive) {
				modelContext.delete(checkin)
				try! modelContext.save()
			}
		}
	}
}

struct CheckinWithoutPlaceCellView: View {
	@Environment(\.modelContext) var modelContext
	let checkin: LocalCheckin

	var body: some View {
		HStack {
			CheckinCellMapView(region: checkin.wrapped.region(.within(meters: 500)))

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
				modelContext.delete(checkin)
				try! modelContext.save()
			}
		}
	}
}

struct CheckinCellView: View {
	let checkin: LocalCheckin

	var body: some View {
		Group {
			if let place = checkin.place {
				NavigationLink(value: Route.checkin(checkin.wrapped, place.wrapped)) {
					CheckinWithPlaceCellView(checkin: checkin, place: place)
				}
			} else {
				NavigationLink(value: Route.checkinChoosePlace(checkin.wrapped)) {
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
				let checkin = LocalCheckin(wrapped: Checkin.preview)
				ModelContainer.preview.mainContext.insert(checkin)
				checkin.place = nil
			}
		}
	}
#endif
