//
//  Debouncer.swift
//  Fourskie
//
//  Created by Pat Nakajima on 6/5/24.
//

import Foundation

public final class Debouncer: @unchecked Sendable {
	@LockAttribute var task: Task<Void, Never>? = nil

	public func debounce(action: @MainActor @Sendable @escaping () -> Void) {
		task?.cancel()
		task = Task { @MainActor in
			do {
				try await Task.sleep(for: .seconds(0.2))
			} catch {
				return
			}

			if Task.isCancelled {
				return
			}

			action()
		}
	}
}
