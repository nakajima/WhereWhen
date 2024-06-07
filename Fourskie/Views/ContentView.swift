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
					case let .finishCheckinView(place, coordinate):
						ManualCheckinFinishView(
							place: place,
							currentLocation: coordinate
						)
					case let .finishUpdateCheckinView(checkin, place):
						ManualCheckinFinishView(
							checkin: LocalCheckin.model(for: checkin, in: modelContext),
							place: place,
							currentLocation: checkin.coordinate
						)
					case let .checkin(checkin, place):
						CheckinShowView(checkin: LocalCheckin.model(for: checkin, in: modelContext), place: LocalPlace.model(for: place, in: modelContext))
					case let .checkinChoosePlace(checkin):
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
