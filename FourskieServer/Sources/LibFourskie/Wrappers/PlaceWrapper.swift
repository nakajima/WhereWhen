//
//  File.swift
//  
//
//  Created by Pat Nakajima on 6/5/24.
//

import Foundation

public protocol SharedWrapper<Wrapped> {
	associatedtype Wrapped: Codable

	var wrapped: Wrapped { get }
	init?(wrapped: Wrapped)
}
