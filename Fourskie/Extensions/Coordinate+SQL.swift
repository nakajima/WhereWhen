//
//  Coordinate+SQL.swift
//  Fourskie
//
//  Created by Pat Nakajima on 6/8/24.
//

import Foundation
import LibFourskie

extension Coordinate {
	var sql: String {
		"""
			GeomFromText('POINT(\(latitude) \(longitude))', 4326)
		"""
	}

	func updateSQL(uuid: String, table: String) -> String {
		"""
		UPDATE \(table) SET coordinate = \(sql) WHERE uuid = '\(uuid)'
		"""
	}
}
