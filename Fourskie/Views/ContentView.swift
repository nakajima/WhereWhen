//
//  ContentView.swift
//  Fourskie
//
//  Created by Pat Nakajima on 5/31/24.
//

import SwiftData
import SwiftUI

enum Route: Hashable {
	case home, settings
}

struct ContentView: View {
	@Environment(\.modelContext) private var modelContext
	@EnvironmentObject var coordinator: FourskieCoordinator

	var body: some View {
		NavigationSplitView {
			HomeView()
				.navigationDestination(for: Route.self) { route in
					switch route {
					case .home: HomeView()
					case .settings: SettingsView()
					}
				}
		} detail: {
			Text("Select an item")
		}
		.sheet(isPresented: $coordinator.isShowingManualCheckin) {
			Text("Hi")
		}
	}
}

#Preview {
	ContentView()
		.modelContainer(for: Checkin.self, inMemory: true)
		.environment(LocationListener(container: ModelContainer.preview))
}
