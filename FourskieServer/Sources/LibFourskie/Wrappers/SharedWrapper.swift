//
//  SharedWrapper.swift
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

public extension SharedWrapper {
	static func decode(_ data: Data) throws -> Self? {
		try .init(wrapped: JSONDecoder().decode(Wrapped.self, from: data))
	}

	static func encode(_ object: Self) throws -> Data {
		try JSONEncoder().encode(object.wrapped)
	}
}
