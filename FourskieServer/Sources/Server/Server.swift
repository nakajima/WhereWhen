//
//  Server.swift
//
//
//  Created by Pat Nakajima on 6/4/24.
//

import Foundation
import Hummingbird
import LibFourskie
import NIOCore
import ServerData
import SQLiteKit

public struct Server {
	public init() {}

	public func run() async throws {
		let encoder = JSONEncoder()
		encoder.outputFormatting = .prettyPrinted

		let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
		let container = Container.sqlite("fourskie.sqlite", on: eventLoopGroup)

		let checkinStore = PersistentStore(for: ServerCheckin.self, container: container)
		let placeStore = PersistentStore(for: ServerCheckin.self, container: container)

		// create router and add a single GET /hello route
		let router = Router()
		router.middlewares.add(LogRequestsMiddleware(.notice))

		router.get("checkins") { _, _ -> ByteBuffer in
			let checkins = try await checkinStore.list()
			let data = try encoder.encode(checkins)
			return ByteBuffer(data: data)
		}

		router.post("checkins") { request, _ -> ByteBuffer in
			let checkinData = try await Data(buffer: request.body.collect(upTo: 1024 * 5))
			guard let checkin = try ServerCheckin.decode(checkinData) else {
				return ByteBuffer(data: Data("Nope".utf8))
			}

			try await checkinStore.save(checkin)

			return ByteBuffer(data: Data("OK".utf8))
		}

		router.get("ping") { _, _ -> String in
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
