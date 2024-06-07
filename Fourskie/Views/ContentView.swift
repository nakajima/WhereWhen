//
//  ContentView.swift
//  Fourskie
//
//  Created by Pat Nakajima on 5/31/24.
//

import LibFourskie
import SwiftData
import SwiftUI

enum Route: Hashable {
	case home,
	     settings,
	     checkin(Checkin, Place),
	     checkinChoosePlace(Checkin),
	     finishCheckinView(Place, Coordinate),
	     finishUpdateCheckinView(Checkin, Place)
}

struct ContentView: View {
	@Environment(\.modelContext) private var modelContext
	@EnvironmentObject var coordinator: FourskieCoordinator

	var body: some View {
		NavigationStack(path: $coordinator.navigation) {
			HomeView()
				.navigationDestination(for: Route.self) { route in
					switch route {
					case .home: HomeView()
					case .settings: SettingsView()
					case .finishCheckinView(let place, let coordinate):
						ManualCheckinFinishView(
							place: place,
							currentLocation: coordinate
						)
					case .finishUpdateCheckinView(let checkin, let place):
						ManualCheckinFinishView(
							checkin: LocalCheckin.model(for: checkin, in: modelContext),
							place: place,
							currentLocation: checkin.coordinate
						)
					case .checkin(let checkin, let place):
						CheckinShowView(checkin: LocalCheckin.model(for: checkin, in: modelContext), place: LocalPlace.model(for: place, in: modelContext))
					case .checkinChoosePlace(let checkin):
						CheckinChoosePlaceView(checkin: LocalCheckin.model(for: checkin, in: modelContext))
					}
				}
		}
		.sheet(isPresented: $coordinator.isShowingManualCheckin) {
			ManualCheckinView()
		}
		.overlay(alignment: .center) {
			if let errorMessage = coordinator.errorMessage {
				ErrorOverlay(message: errorMessage)
			}
		}
	}
}

#if DEBUG
#Preview {
	ContentView()
		.modelContainer(ModelContainer.preview)
		.environmentObject(FourskieCoordinator(container: ModelContainer.preview))
		.environment(LocationListener(container: ModelContainer.preview))
}
#endif
