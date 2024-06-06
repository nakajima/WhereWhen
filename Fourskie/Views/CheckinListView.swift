//
//  CheckinListView.swift
//  Fourskie
//
//  Created by Pat Nakajima on 6/4/24.
//

import Foundation
import LibFourskie
import SwiftData
import SwiftUI

struct CheckinListView: View {
	@Query(sort: \LocalCheckin.savedAt, order: .reverse) var checkins: [LocalCheckin]
	@EnvironmentObject var coordinator: FourskieCoordinator

	var body: some View {
		if checkins.isEmpty {
			ContentUnavailableView {
				Label("No checkins yet", systemImage: "mappin.slash")
			} actions: {
				Button("Add One Manually…") {
					coordinator.isShowingManualCheckin = true
				}
				.buttonStyle(.borderedProminent)
				.padding(.top)
			}
		}

		ForEach(checkins) { checkin in
			CheckinCellView(checkin: checkin)
		}
	}
}

#if DEBUG
	#Preview {
		PreviewsWrapper {
			CheckinListView()
				.onAppear {
					ModelContainer.preview.mainContext.insert(LocalCheckin(wrapped: Checkin.preview))
				}
		}
	}
#endif
