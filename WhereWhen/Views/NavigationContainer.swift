//
//  NavigationContainer.swift
//  WhereWhen
//
//  Created by Pat Nakajima on 6/7/24.
//

import LibWhereWhen
import SwiftUI

enum Route: Hashable {
	case home,
	     settings,
	     checkin(Checkin, Place),
	     checkinChoosePlace(Checkin),
	     finishCheckinView(Place, Coordinate),
	     finishUpdateCheckinView(Checkin, Place),
	     createPlace(Coordinate, Checkin?)
}

struct NavigationContainer<Content: View>: View {
	@EnvironmentObject var coordinator: WhereWhenCoordinator

	@Binding var path: [Route]
	@ViewBuilder var content: () -> Content

	var body: some View {
		NavigationStack(path: $path) {
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
							checkin: checkin,
							place: place,
							currentLocation: checkin.coordinate
						)
					case let .checkin(checkin, place):
						CheckinShowView(checkin: checkin, place: place)
					case let .checkinChoosePlace(checkin):
						CheckinEditPlaceView(checkin: checkin)
					case let .createPlace(coordinate, checkin):
						CreatePlaceView(coordinate: coordinate, checkin: checkin)
					}
				}
		}
		.environment(\.navigationPath, $path)
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
