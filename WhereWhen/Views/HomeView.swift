//
//  HomeView.swift
//  WhereWhen
//
//  Created by Pat Nakajima on 6/4/24.
//

import Foundation
import LibWhereWhen
import SwiftUI

struct HomeView: View {
	@Environment(\.database) var database
	@Environment(LocationListener.self) var location
	@Environment(\.coordinator) var coordinator

	@State private var currentTab = 0
	@State private var lastCurrentTab = 0

	var body: some View {
		TabView(selection: $currentTab.animation()) {
			HomeCheckinPlacesListView()
				.tag(0)
				.tabItem {
					Label("Home", systemImage: "list.star")
				}

			ProgressView()
				.tag(1)
				.onAppear {
					coordinator.isShowingManualCheckin = true
				}
				.onChange(of: coordinator.isShowingManualCheckin) {
					if !coordinator.isShowingManualCheckin {
						withAnimation {
							currentTab = lastCurrentTab
						}
					}
				}
				.tabItem {
					Label("Checkin", systemImage: "mappin.and.ellipse.circle.fill")
				}

			HomeMapView()
				.tag(2)
				.tabItem {
					Label("Map", systemImage: "map")
				}
		}
		.onChange(of: currentTab) {
			// Let us restore whatever tab we were on before when the user dismisses
			// the manual checkin sheet
			print("currentTab now \(currentTab)")
			if currentTab != 1 {
				lastCurrentTab = currentTab
			}
		}
	}
}

#if DEBUG
	#Preview {
		PreviewsWrapper {
			HomeView()
				.onAppear {
					try! Checkin.preview.save(to: .memory)
				}
		}
	}
#endif
