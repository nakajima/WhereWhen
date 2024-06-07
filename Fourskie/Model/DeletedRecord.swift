//
//  DeletedRecord.swift
//  Fourskie
//
//  Created by Pat Nakajima on 6/7/24.
//

import Foundation
import GRDB

public protocol DeleteSyncable {
	var uuid: String { get }
}

// Tracks deletions of stuff so we can let the server know.
public struct DeletedRecord: Sendable, Codable, Model {
	static func create(in database: Database) throws {
		try database.create(table: "deletedRecord") { t in
			t.primaryKey("uuid", .text)
			t.column("type", .text)
			t.column("deletedAt", .datetime)
		}
	}

	public var uuid: String
	public var type: String
	public var deletedAt: Date

	public init(uuid: String, type: String, deletedAt: Date) {
		self.uuid = uuid
		self.type = type
		self.deletedAt = deletedAt
	}
}
