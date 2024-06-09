//
//  CheckinEditPlaceView.swift
//  Fourskie
//
//  Created by Pat Nakajima on 6/6/24.
//

import Foundation
import LibFourskie
import SwiftUI

struct UpdateCheckinView: View {
	var checkin: Checkin
	var place: Place

	var body: some View {
		ManualCheckinFinishView(
			place: place,
			currentLocation: checkin.coordinate,
			caption: "Setting Checkin Place"
		)
	}
}

struct CheckinEditPlaceView: View {
	@EnvironmentObject var coordinator: FourskieCoordinator
	let checkin: Checkin

	var body: some View {
		ChoosePlaceView(location: checkin.coordinate) { place in
			.finishUpdateCheckinView(checkin, place)
		}
		.navigationTitle("Choose a place")
	}
}

#if DEBUG
	#Preview {
		PreviewsWrapper {
			NavigationStack {
				CheckinEditPlaceView(checkin: Checkin.preview)
			}
		}
	}
#endif
