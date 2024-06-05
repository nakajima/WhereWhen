//
//  ManualCheckinView.swift
//  Fourskie
//
//  Created by Pat Nakajima on 6/4/24.
//

import CoreLocation
import Foundation
import MapKit
import SwiftData
import SwiftUI

struct ManualCheckinView: View {
	@Environment(LocationListener.self) var location

	@State private var status: Status = .loading

	enum Status {
		case loading, loaded(CLLocation), error(String)
	}

	var body: some View {
		NavigationStack {
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
							self.status = .error(error.localizedDescription)
						}
					}
			case .loaded(let clLocation):
				ManualCheckinChoosePlaceView(location: clLocation)
					.navigationTitle("Check In")
					.navigationBarTitleDisplayMode(.inline)
			case .error(let string):
				Text("Error fetching location: \(string)")
			}
		}
	}
}

#if DEBUG
#Preview {
	ManualCheckinView()
		.environment(LocationListener(container: ModelContainer.preview))
		.environmentObject(FourskieCoordinator(container: ModelContainer.preview))
		.modelContainer(ModelContainer.preview)
}
#endif
