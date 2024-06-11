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

struct DatabaseKey: EnvironmentKey {
	static let defaultValue: DatabaseContainer = .memory
}

struct NavigationPathKey: EnvironmentKey {
	static let defaultValue: Binding<[Route]> = Binding(get: { [] }, set: { _ in })
}

extension EnvironmentValues {
	var database: DatabaseContainer {
		get { self[DatabaseKey.self] }
		set { self[DatabaseKey.self] = newValue }
	}

	var navigationPath: Binding<[Route]> {
		get { self[NavigationPathKey.self] }
		set { self[NavigationPathKey.self] = newValue }
	}
}
