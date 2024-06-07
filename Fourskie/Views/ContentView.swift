//
//  ContentView.swift
//  Fourskie
//
//  Created by Pat Nakajima on 5/31/24.
//

import LibFourskie
import SwiftData
import SwiftUI

struct ContentView: View {
	@Environment(\.modelContext) private var modelContext
	@EnvironmentObject var coordinator: FourskieCoordinator

	var body: some View {
		NavigationContainer(path: $coordinator.navigation) {
			HomeView()
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
