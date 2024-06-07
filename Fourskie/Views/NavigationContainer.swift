//
//  NavigationContainer.swift
//  Fourskie
//
//  Created by Pat Nakajima on 6/7/24.
//

import LibFourskie
import SwiftUI

enum Route: Hashable {
	case home,
	     settings,
	     checkin(Checkin, Place),
	     checkinChoosePlace(Checkin),
	     finishCheckinView(Place, Coordinate),
	     finishUpdateCheckinView(Checkin, Place)
}

struct NavigationContainer<Content: View>: View {
	@EnvironmentObject var coordinator: FourskieCoordinator
	@Environment(\.modelContext) private var modelContext

	var path: Binding<[Route]>
	@ViewBuilder var content: () -> Content

	var body: some View {
		NavigationStack(path: path) {
			content()
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
	}
}

#if DEBUG
#Preview {
	PreviewsWrapper {
		NavigationContainer(path: .constant([])) {
			Text("Hi")
		}
	}
}
#endif
