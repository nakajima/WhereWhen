//
//  CheckinListView.swift
//  WhereWhen
//
//  Created by Pat Nakajima on 6/4/24.
//

import Foundation
import GRDB
import GRDBQuery
import LibWhereWhen
import SwiftUI

struct CheckinListView: View {
	@Query(CheckinListRequest(), in: \.database.queue) var checkins: [Checkin]

	@EnvironmentObject var coordinator: WhereWhenCoordinator

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
					try! Checkin.preview.save(to: Database.memory)
				}
		}
	}
#endif
