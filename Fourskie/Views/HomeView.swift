//
//  HomeView.swift
//  Fourskie
//
//  Created by Pat Nakajima on 6/4/24.
//

import Foundation
import SwiftUI
import SwiftData

struct HomeView: View {
	@Environment(LocationListener.self) var location

	@AppStorage("isLocationPromptDismissed") var isLocationPromptDismissed = false

	var body: some View {
		List {
			Text("hi")
		}
		.toolbar {
			ToolbarItem(placement: .navigationBarLeading) {
				NavigationLink(value: Route.settings) {
					Label("Settings", systemImage: "gearshape")
				}
			}
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

#Preview {
	NavigationSplitView {
		HomeView()
	} detail: {
		Text("hi")
	}
	.environment(LocationListener(container: ModelContainer.preview))
}
