//
//  File.swift
//  
//
//  Created by Pat Nakajima on 6/5/24.
//

import Foundation

// Types conforming to shared wrapper can be sent between
// client and server serialized as their Wrapped type.
public protocol SharedWrapper<Wrapped> {
	associatedtype Wrapped: Codable

	var wrapped: Wrapped { get }
	init?(wrapped: Wrapped)
}
