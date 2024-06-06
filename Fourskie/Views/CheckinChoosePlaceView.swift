//
//  CheckinChoosePlaceView.swift
//  Fourskie
//
//  Created by Pat Nakajima on 6/6/24.
//

import Foundation
import LibFourskie
import SwiftUI

struct CheckinChoosePlaceView: View {
	let checkin: LocalCheckin

	var body: some View {
		ManualCheckinChoosePlaceView(location: checkin.coordinate) { place in
			ManualCheckinFinishView(
				place: place,
				currentLocation: checkin.coordinate,
				caption: "Setting Checkin Place",
				buttonLabel: "Set Checkin Place"
			)
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
