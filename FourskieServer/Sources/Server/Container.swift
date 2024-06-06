//
//  Container.swift
//
//
//  Created by Pat Nakajima on 6/4/24.
//

import Foundation
import NIOCore
import ServerData
import SQLiteKit

extension Container {
	static func sqlite(_ name: String, on eventLoopGroup: EventLoopGroup) -> Container {
		// Configure our SQLite database so we can create a ServerData Container
		let config = SQLiteConfiguration(storage: .file(path: name))
		let source = SQLiteConnectionSource(configuration: config)
		let pool = EventLoopGroupConnectionPool(source: source, on: eventLoopGroup)
		let connection = try! source.makeConnection(logger: Logger(label: name), on: pool.eventLoopGroup.next()).wait()
		let database = connection.sql()

		// Create the Container so we can use it to create a PersistentStore for
		// our Person model
		let container = try! Container(
			name: name,
			database: database,
			shutdown: {
				pool.shutdown()
				try! connection.close().wait()
			}
		)

		return container
	}
}
