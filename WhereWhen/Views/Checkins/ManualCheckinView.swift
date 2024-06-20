//
//  ManualCheckinView.swift
//  WhereWhen
//
//  Created by Pat Nakajima on 6/4/24.
//

import CoreLocation
import Foundation
import MapKit
import SwiftUI

struct ManualCheckinView: View {
	@EnvironmentObject var coordinator: WhereWhenCoordinator
	@Environment(LocationListener.self) var location

	@State private var status: Status = .loading
	@State private var path: [Route] = []

	enum Status {
		case loading, loaded(CLLocation), error(String)
	}

	var body: some View {
		switch status {
		case .loading:
			ProgressView("Finding Your Location…")
				.task {
					if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
						let coord = CLLocationCoordinate2D(latitude: 37.33233141, longitude: -122.03121860)
						let clLocation = CLLocation(coordinate: coord, altitude: 0, horizontalAccuracy: kCLLocationAccuracyNearestTenMeters, verticalAccuracy: kCLLocationAccuracyNearestTenMeters, timestamp: Date())
						self.status = .loaded(clLocation)
						return
					}

					do {
						let currentLocation = try await location.requestCurrent()
						self.status = .loaded(currentLocation)
					} catch {
						withAnimation {
							if let error = error as? CLError {
								self.status = .error(error.description)
								return
							}

							self.status = .error(error.localizedDescription)
						}
					}
				}
		case let .loaded(clLocation):
			NavigationContainer(path: $path) {
				ChoosePlaceView(
					location: .init(clLocation.coordinate),
					destination: { place in .finishCheckinView(place, .init(clLocation.coordinate)) }
				)
				.navigationTitle("Check In")
				.navigationBarTitleDisplayMode(.inline)
			}
		case let .error(string):
			ContentUnavailableView {
				Label("Could not find your location", systemImage: "mappin.slash")
			} description: {
				Text(string)
				Button(action: {
					withAnimation {
						self.status = .loading
					}
				}) {
					Text("Try Again")
				}
				.buttonStyle(.borderedProminent)
				.buttonBorderShape(.capsule)
			}
		}
	}
}

#if DEBUG
	#Preview {
		PreviewsWrapper {
			ManualCheckinView()
		}
	}
#endif
