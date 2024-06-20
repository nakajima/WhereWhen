//
//  HomeCheckinPlacesListView.swift
//  WhereWhen
//
//  Created by Pat Nakajima on 6/20/24.
//

import Foundation
import SwiftUI

struct HomeCheckinPlacesListView: View {
	@Environment(\.database) var database
	@Environment(LocationListener.self) var location
	@EnvironmentObject var coordinator: WhereWhenCoordinator

	var body: some View {
		List {
			CheckinListView()
		}
		.refreshable {
			coordinator.sync()
		}
		.toolbar {
			ToolbarItem(placement: .navigationBarLeading) {
				NavigationLink(value: Route.settings) {
					Label("Settings", systemImage: "gearshape")
				}
			}
		}
		.safeAreaInset(edge: .bottom) {
			if location.isAuthorized {
				Button("Check In") {
					coordinator.isShowingManualCheckin = true
				}
				.buttonStyle(.borderedProminent)
				.controlSize(.large)
				.clipShape(RoundedRectangle(cornerRadius: 32))
			}
		}
		.safeAreaInset(edge: .bottom) {
			RequestLocationAccessView()
		}
		.navigationBarTitleDisplayMode(.inline)
		.navigationTitle("Places")
	}
}
