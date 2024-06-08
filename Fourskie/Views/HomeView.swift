//
//  HomeView.swift
//  Fourskie
//
//  Created by Pat Nakajima on 6/4/24.
//

import Foundation
import LibFourskie
import SwiftUI

struct HomeView: View {
	@Environment(\.database) var database
	@Environment(LocationListener.self) var location
	@EnvironmentObject var coordinator: FourskieCoordinator
	@AppStorage("isLocationPromptDismissed") var isLocationPromptDismissed = false

	var body: some View {
		List {
			CheckinListView()
		}
		.task {
			let checkins = try! Checkin.all(in: database)
			for checkin in checkins {
				try! checkin.syncCoordinate(in: database)
			}

			let checkinPoints = try! database.queue.spatialite { db in
				try String?.fetchAll(db, sql: "SELECT AsText(coordinate) FROM checkin")
			}

			print("checkin points: \(checkinPoints)")
		}
		.toolbar {
			ToolbarItem(placement: .navigationBarLeading) {
				NavigationLink(value: Route.settings) {
					Label("Settings", systemImage: "gearshape")
				}
			}
		}
		.safeAreaInset(edge: .bottom) {
			Button("Check In") {
				coordinator.isShowingManualCheckin = true
			}
			.buttonStyle(.borderedProminent)
			.controlSize(.large)
			.clipShape(RoundedRectangle(cornerRadius: 32))
		}
		.safeAreaInset(edge: .bottom) {
			if !location.isAuthorized, !isLocationPromptDismissed {
				VStack {
					Text("Hey you should probably grant location access. Otherwise there’s not much point to this app.")
						.frame(maxWidth: .infinity, alignment: .leading)
						.padding(.top)
					HStack {
						Button(action: {
							location.requestAuthorization()
						}) {
							Text("Grant…")
								.frame(maxWidth: .infinity)
						}
						.buttonStyle(.borderedProminent)
						Button(action: {}) {
							Text("I shan’t.")
								.frame(maxWidth: .infinity)
						}
						.foregroundStyle(.primary)
						.buttonStyle(.bordered)
					}
				}
				.padding(.horizontal)
				.padding(.bottom)
				.background(.fill)
				.font(.subheadline)
			}
		}
		.navigationBarTitleDisplayMode(.inline)
		.navigationTitle("Places")
	}
}

#if DEBUG
	#Preview {
		PreviewsWrapper {
			NavigationContainer(path: .constant([])) {
				HomeView()
			}
		}
	}
#endif
