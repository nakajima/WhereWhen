//
//  Environment.swift
//  WhereWhen
//
//  Created by Pat Nakajima on 6/7/24.
//

import Database
import Foundation
import GRDB
import SwiftUI

struct LocationKey: EnvironmentKey {
	static let defaultValue: LocationListener = .init(database: .memory)
}

struct DatabaseKey: EnvironmentKey {
	static let defaultValue: DatabaseContainer = .memory
}

struct NavigationPathKey: EnvironmentKey {
	static let defaultValue: Binding<[Route]> = Binding(get: { [] }, set: { _ in })
}

struct CoordinatorKey: EnvironmentKey {
	static let defaultValue: WhereWhenCoordinator = .init(database: .dev)
}

extension EnvironmentValues {
	var location: LocationListener {
		get { self[LocationKey.self] }
		set { self[LocationKey.self] = newValue }
	}

	var coordinator: WhereWhenCoordinator {
		get { self[CoordinatorKey.self] }
		set { self[CoordinatorKey.self] = newValue }
	}

	var database: DatabaseContainer {
		get { self[DatabaseKey.self] }
		set { self[DatabaseKey.self] = newValue }
	}

	var navigationPath: Binding<[Route]> {
		get { self[NavigationPathKey.self] }
		set { self[NavigationPathKey.self] = newValue }
	}
}
