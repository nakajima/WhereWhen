//
//  File.swift
//  Fourskie
//
//  Created by Pat Nakajima on 6/4/24.
//

import Foundation
import SwiftData

extension ModelContainer {
	fileprivate static let models: [any PersistentModel.Type] = [
		LocalCheckin.self,
		LocalPlace.self
	]

	static let shared = {
		let schema = Schema(models)
		let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

		do {
			return try ModelContainer(for: schema, configurations: [modelConfiguration])
		} catch {
			fatalError("Could not create ModelContainer: \(error)")
		}
	}()

	#if DEBUG
	static let preview = {
		let schema = Schema(models)
		let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)

		do {
			return try ModelContainer(for: schema, configurations: [modelConfiguration])
		} catch {
			fatalError("Could not create ModelContainer: \(error)")
		}
	}()
	#endif
}
