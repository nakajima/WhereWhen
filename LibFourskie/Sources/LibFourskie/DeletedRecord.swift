//
//  DeletedRecord.swift
//
//
//  Created by Pat Nakajima on 6/7/24.
//

import Foundation

public struct DeletedRecord: Codable, Sendable, Hashable {
	public var uuid: String
	public var type: String
	public var deletedAt: Date

	public init(uuid: String, type: String, deletedAt: Date) {
		self.uuid = uuid
		self.type = type
		self.deletedAt = deletedAt
	}
}
