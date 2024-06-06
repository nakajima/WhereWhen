//
//  ModelContext.swift
//  Fourskie
//
//  Created by Pat Nakajima on 6/5/24.
//

import Foundation
import SwiftData

extension ModelContext {
	func first<T: PersistentModel>(where predicate: Predicate<T>) throws -> T? {
		let descriptor = FetchDescriptor<T>(predicate: predicate)
		return try fetch(descriptor).first
	}
}
