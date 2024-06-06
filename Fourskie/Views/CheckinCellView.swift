//
//  CheckinCellView.swift
//  Fourskie
//
//  Created by Pat Nakajima on 6/5/24.
//

import LibFourskie
import SwiftData
import SwiftUI
import MapKit

struct CheckinCellView: View {
	let checkin: LocalCheckin

	var body: some View {
		if let place = checkin.place {
			HStack {
				Map(initialPosition: .region(place.wrapped.region))
			}
		} else {
			HStack {
			}
		}

	}
}

#if DEBUG
#Preview {
	PreviewsWrapper {
		CheckinListView()
			.onAppear {
				ModelContainer.preview.mainContext.insert(
					LocalCheckin(wrapped: Checkin.preview)
				)
			}
	}
}
#endif
