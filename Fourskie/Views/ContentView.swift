//
//  ContentView.swift
//  Fourskie
//
//  Created by Pat Nakajima on 5/31/24.
//

import LibFourskie
import SwiftUI

struct ContentView: View {
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
			.environment(\.database, .memory)
			.environmentObject(FourskieCoordinator(database: .memory))
			.environment(LocationListener(database: .memory))
	}
#endif
