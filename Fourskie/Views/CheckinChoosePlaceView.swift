//
//  CheckinChoosePlaceView.swift
//  Fourskie
//
//  Created by Pat Nakajima on 6/6/24.
//

import Foundation
import LibFourskie
import SwiftData
import SwiftUI

struct UpdateCheckinView: View {
	var checkin: LocalCheckin
	var place: Place

	var body: some View {
		ManualCheckinFinishView(
			place: place,
			currentLocation: checkin.coordinate,
			caption: "Setting Checkin Place",
			buttonLabel: "Set Checkin Place"
		)
	}
}

struct CheckinChoosePlaceView: View {
	@EnvironmentObject var coordinator: FourskieCoordinator
	@Environment(\.modelContext) var modelContext
	let checkin: LocalCheckin

	var body: some View {
		ManualCheckinChoosePlaceView(location: checkin.coordinate) { place in
			.finishUpdateCheckinView(checkin.wrapped, place)
		}
		.navigationTitle("Choose a place")
	}
}

#if DEBUG
	#Preview {
		PreviewsWrapper {
			NavigationStack {
				CheckinChoosePlaceView(checkin: LocalCheckin(wrapped: Checkin.preview))
			}
		}
	}
#endif
