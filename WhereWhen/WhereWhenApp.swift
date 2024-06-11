//
//  WhereWhenApp.swift
//  WhereWhen
//
//  Created by Pat Nakajima on 5/31/24.
//

import SwiftUI
import UIKit

@main
struct WhereWhenApp: App {
	@StateObject var coordinator: WhereWhenCoordinator

	let location = LocationListener(database: .dev)

	init() {
		_coordinator = StateObject(
			wrappedValue: WhereWhenCoordinator(database: .dev)
		)
	}

	var body: some Scene {
		WindowGroup {
			ContentView()
				.environmentObject(coordinator)
		}
		.environment(location)
		.environment(\.database, .dev)
	}
}
