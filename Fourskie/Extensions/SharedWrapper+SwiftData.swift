//
//  SharedWrapper+SwiftData.swift
//  Fourskie
//
//  Created by Pat Nakajima on 6/6/24.
//

import Foundation
import LibFourskie
import SwiftData

extension SharedWrapper where Self: PersistentModel {
	static func model(for wrapped: Wrapped, in context: ModelContext) -> Self {
		if let existing = try? context.first(where: #Predicate<Self> { $0.uuid == wrapped.uuid }) {
			return existing
		}

		return Self.init(wrapped: wrapped)!
	}
}
