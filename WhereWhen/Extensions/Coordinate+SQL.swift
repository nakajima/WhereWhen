//
//  Coordinate+SQL.swift
//  WhereWhen
//
//  Created by Pat Nakajima on 6/8/24.
//

import Foundation
import GRDB
import LibWhereWhen

extension Coordinate: DatabaseValueConvertible, RawRepresentable {
	public init?(rawValue: String) {
		nil
	}
	
	public var rawValue: String {
		sql
	}
	
	public typealias RawValue = String

	var sql: String {
		"""
		MakePoint(\(latitude), \(longitude), 4326)
		"""
	}

	func updateSQL(uuid: String, table: String) -> String {
		"""
		UPDATE \(table) SET spatialCoordinate = \(sql) WHERE uuid = '\(uuid)'
		"""
	}
}
