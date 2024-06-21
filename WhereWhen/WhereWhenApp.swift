//
//  WhereWhenApp.swift
//  WhereWhen
//
//  Created by Pat Nakajima on 5/31/24.
//

import Database
import SwiftUI
import UIKit

@main
struct WhereWhenApp: App {
	@State var coordinator: WhereWhenCoordinator

	let database: DatabaseContainer
	let location: LocationListener

	init() {
		let database = DatabaseContainer.dev

		self.database = database
		self.location = LocationListener(database: database)
		self._coordinator = State(
			wrappedValue: WhereWhenCoordinator(database: database)
		)
	}

	var body: some Scene {
		WindowGroup {
			ContentView()
				.task(priority: .low) { @MainActor in
					let debouncer = Debouncer(wait: .seconds(1))
					do {
						try await Task.sleep(for: .seconds(1))
						for try await _ in coordinator.database.updates {
							debouncer.debounce { @MainActor in
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
		.environment(\.coordinator, coordinator)
	}
}
