//
//  CheckinListView.swift
//  Fourskie
//
//  Created by Pat Nakajima on 6/4/24.
//

import Foundation
import SwiftUI
import SwiftData

struct CheckinListView: View {
	@Query var checkins: [LocalCheckin]
	@EnvironmentObject var coordinator: FourskieCoordinator

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
			VStack {
				Text("Lat: \(checkin.coordinate.latitude) Lng: \(checkin.coordinate.longitude)")
				Text("Saved at \(checkin.savedAt), Arrival: \(checkin.arrivalDate), Departure: \(checkin.departureDate)")
			}
		}
	}
}
