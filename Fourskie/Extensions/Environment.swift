//
//  Environment.swift
//  Fourskie
//
//  Created by Pat Nakajima on 6/7/24.
//

import Foundation
import GRDB
import SwiftUI

struct DatabaseKey: EnvironmentKey {
	static let defaultValue: Database = .memory
}

extension EnvironmentValues {
	var database: Database {
		get { self[DatabaseKey.self] }
		set { self[DatabaseKey.self] = newValue }
	}
}
