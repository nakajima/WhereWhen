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
				.task(priority: .low) {
					let debouncer = Debouncer(wait: .seconds(1))

					do {
						for try await update in coordinator.database.updates {
							debouncer.debounce {
								print("*** DATABASE UPDATED \(update) ***")
								coordinator.sync()
							}
						}
					} catch {
						print("Error: \(error)")
					}
				}
		}
		.environment(location)
		.environment(\.database, .dev)
	}
}
