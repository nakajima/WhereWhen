//
//  ContentView.swift
//  WhereWhen
//
//  Created by Pat Nakajima on 5/31/24.
//

import LibWhereWhen
import SwiftUI

struct ContentView: View {
	@EnvironmentObject var coordinator: WhereWhenCoordinator
	@State private var path: [Route] = []

	var body: some View {
		NavigationContainer(path: $path) {
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
			.environmentObject(WhereWhenCoordinator(database: .memory))
			.environment(LocationListener(database: .memory))
	}
#endif
