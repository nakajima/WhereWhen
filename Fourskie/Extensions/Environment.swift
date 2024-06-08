//
//  Environment.swift
//  Fourskie
//
//  Created by Pat Nakajima on 6/7/24.
//

import Foundation
import SwiftUI
import GRDB

struct DatabaseKey: EnvironmentKey {
	static let defaultValue: Database = .memory
}

private struct DatabaseQueueKey: EnvironmentKey {
	/// The default dbQueue is an empty in-memory database
	static var defaultValue: DatabaseQueue { try! DatabaseQueue() }
}

extension EnvironmentValues {
	var database: Database {
		get { self[DatabaseKey.self] }
		set { self[DatabaseKey.self] = newValue }
	}

	var dbQueue: DatabaseQueue {
		get { self[DatabaseQueueKey.self] }
		set { self[DatabaseQueueKey.self] = newValue }
	}
}
