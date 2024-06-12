//
//  Debouncer.swift
//  WhereWhen
//
//  Created by Pat Nakajima on 6/5/24.
//

import Foundation

public final class Debouncer: @unchecked Sendable {
	@LockAttribute var task: Task<Void, Never>? = nil

	let wait: Duration

	init(wait: Duration = .seconds(0.2)) {
		self.wait = wait
	}

	public func debounce(action: @MainActor @Sendable @escaping () -> Void) {
		task?.cancel()
		task = Task { @MainActor [weak self] in
			guard let self else { return }

			do {
				try await Task.sleep(for: wait)
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
