//
//  ContentView.swift
//  WhereWhen
//
//  Created by Pat Nakajima on 5/31/24.
//

import LibWhereWhen
import SwiftUI

struct ContentView: View {
	@Environment(\.coordinator) var coordinator
	@State private var path: [Route] = []

	var body: some View {
		HomeView()
			.sheet(isPresented: coordinator.binding(\.isShowingManualCheckin)) {
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
			.environment(\.coordinator, WhereWhenCoordinator(database: .memory))
			.environment(LocationListener(database: .memory))
	}
#endif
