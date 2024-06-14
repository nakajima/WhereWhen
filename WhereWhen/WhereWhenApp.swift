//
//  WhereWhenApp.swift
//  WhereWhen
//
//  Created by Pat Nakajima on 5/31/24.
//

import SwiftUI
import Database
import UIKit

@main
struct WhereWhenApp: App {
	@StateObject var coordinator: WhereWhenCoordinator

	let database: DatabaseContainer
	let location: LocationListener

	init() {
		let database = DatabaseContainer.dev

		self.database = database
		self.location = LocationListener(database: database)
		self._coordinator = StateObject(
			wrappedValue: WhereWhenCoordinator(database: database)
		)
	}

	var body: some Scene {
		WindowGroup {
			ContentView()
				.environmentObject(coordinator)
				.task(priority: .low) { @MainActor in
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
		.environment(\.database, database)
	}
}
