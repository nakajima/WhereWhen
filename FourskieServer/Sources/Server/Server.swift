//
//  File.swift
//
//
//  Created by Pat Nakajima on 6/4/24.
//

import Foundation
import Hummingbird
import NIOCore
import SQLiteKit
import ServerData

public struct Server {
	public init() {}

	public func run() async throws {
		let encoder = JSONEncoder()
		encoder.outputFormatting = .prettyPrinted

		let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
		let container = Container.sqlite("fourskie.sqlite", on: eventLoopGroup)

		let store = PersistentStore(for: ServerCheckin.self, container: container)

		// create router and add a single GET /hello route
		let router = Router()
		router.middlewares.add(LogRequestsMiddleware(.notice))

		router.get("checkins") { request, context -> ByteBuffer in
			let checkins = try await store.list()
			let data = try encoder.encode(checkins)
			return ByteBuffer(data: data)
		}

		router.post("checkins") { request, context -> ByteBuffer in

		}

		router.get("ping") { request, context -> String in
			"PONG (\(Date().ISO8601Format()))\n"
		}

		// create application using router
		let app = Application(
			router: router,
			configuration: .init(address: .hostname("127.0.0.1", port: 4567)),
			eventLoopGroupProvider: .shared(eventLoopGroup)
		)

		// run hummingbird application
		try await app.runService()
	}
}
