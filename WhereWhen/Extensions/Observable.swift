//
//  Observable.swift
//  WhereWhen
//
//  Created by Pat Nakajima on 6/21/24.
//

import Foundation
import SwiftUI

extension Observable {
	func binding<T>(_ keyPath: ReferenceWritableKeyPath<Self, T>) -> Binding<T> {
		Binding<T>(
			get: {
				self[keyPath: keyPath]
			},
			set: { newValue in
				self[keyPath: keyPath] = newValue
			}
		)
	}
}
