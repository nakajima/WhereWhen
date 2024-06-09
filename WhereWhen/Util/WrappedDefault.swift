//
//  WrappedDefault.swift
//  WhereWhen
//
//  Created by Pat Nakajima on 6/6/24.
//

import Foundation

@propertyWrapper
public struct UserDefault<T> {
	private let defaultValue: T
	private let defaults: UserDefaults

	public let key: String

	public var wrappedValue: T {
		get {
			defaults.value(forKey: key) as? T ?? defaultValue
		}
		set {
			defaults.set(newValue, forKey: key)
		}
	}

	public init(
		_ keyName: String,
		defaultValue: T,
		userDefaults: UserDefaults = .standard
	) {
		self.key = keyName
		self.defaultValue = defaultValue
		self.defaults = userDefaults
	}
}
