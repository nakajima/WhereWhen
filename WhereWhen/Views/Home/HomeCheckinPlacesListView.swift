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
			RequestLocationAccessView()
		}
		.navigationBarTitleDisplayMode(.inline)
		.navigationTitle("Places")
	}
}
