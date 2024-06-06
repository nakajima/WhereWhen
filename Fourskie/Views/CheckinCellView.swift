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

struct CheckinCellView: View {
	let checkin: LocalCheckin

	var body: some View {
		if let place = checkin.place {
			HStack {
				Map(initialPosition: .region(place.wrapped.region))
					.frame(width: 64, height: 64)
					.overlay {
						Image(systemName: "mappin")
							.foregroundStyle(Color.accentColor)
					}

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
				Button("Delete", role: .destructive) {}
			}
		} else {
			HStack {}
		}
	}
}

#if DEBUG
#Preview {
	PreviewsWrapper {
		List {
			CheckinListView()
		}
		.onAppear {
			ModelContainer.preview.mainContext.insert(
				LocalCheckin(wrapped: Checkin.preview)
			)
		}
	}
}
#endif
