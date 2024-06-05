//
//  File.swift
//  Fourskie
//
//  Created by Pat Nakajima on 6/4/24.
//

import Foundation
import SwiftData

extension ModelContainer {
	fileprivate static let models = [
		Checkin.self
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

	static let preview = {
		let schema = Schema(models)
		let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)

		do {
			return try ModelContainer(for: schema, configurations: [modelConfiguration])
		} catch {
			fatalError("Could not create ModelContainer: \(error)")
		}
	}()
}
