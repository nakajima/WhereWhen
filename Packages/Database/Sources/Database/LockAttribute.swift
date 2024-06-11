//
//  LockAttribute.swift
//  WhereWhen
//
//  Created by Pat Nakajima on 6/5/24.
//

import Foundation
import os

@propertyWrapper public struct LockAttribute<T>: Sendable {
	let lock: OSAllocatedUnfairLock<T>

	public var wrappedValue: T {
		get {
			return lock.withLock { state in state }
		}
		set {
			lock.withLock { state in state = newValue }
		}
	}

	public init(wrappedValue: T) {
		self.lock = OSAllocatedUnfairLock(initialState: wrappedValue)
	}
}
