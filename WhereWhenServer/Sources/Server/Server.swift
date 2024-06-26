//
//  Server.swift
//
//
//  Created by Pat Nakajima on 6/4/24.
//

import Foundation
import Hummingbird
import LibWhereWhen
import NIOCore
import ServerData
import SQLiteKit

public struct Server {
	let dbLocation = ProcessInfo.processInfo.environment["DBDIR"] ?? "."
	let port = ProcessInfo.processInfo.environment["PORT"].flatMap { Int($0) } ?? 4567

	public init() {}

	public func run() async throws {
		let encoder = JSONEncoder()
		encoder.outputFormatting = .prettyPrinted

		let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
		let container = Container.sqlite("\(dbLocation)/wherewhen.sqlite", on: eventLoopGroup)

		let checkinStore = PersistentStore(for: ServerCheckin.self, container: container)
		await checkinStore.setup()
		let placeStore = PersistentStore(for: ServerPlace.self, container: container)
		await placeStore.setup()
		let deletionStore = PersistentStore(for: DeletedRecord.self, container: container)
		await deletionStore.setup()

		// create router and add a single GET /hello route
		let router = Router()
		router.middlewares.add(LogRequestsMiddleware(.notice))

		router.get("last-sync-at") { _, _ -> String in
			let lastCheckin = try await checkinStore.first(sort: .descending(\.savedAt))
			let data = try JSONEncoder().encode(lastCheckin?.savedAt)
			return String(data: data, encoding: .utf8) ?? ""
		}

		// TODO: Respect If-Not-Modified
		router.get("checkins") { _, context -> ByteBuffer in
			do {
				let checkins = try await checkinStore.list()

				// TODO: add relationships to serverdata
				var checkinsWithPlaces: [Checkin] = []
				for serverCheckin in checkins {
					var checkin = serverCheckin.wrapped
					let uuid = serverCheckin.placeUUID
					checkin.place = try! await placeStore.first(where: #SQL { $0.uuid == uuid })?.wrapped
					checkinsWithPlaces.append(checkin)
				}

				let data = try encoder.encode(checkinsWithPlaces)
				return ByteBuffer(data: data)
			} catch {
				context.logger.error("error serving checkins: \(error)")
				return .init()
			}
		}

		router.post("deletions") { request, _ -> ByteBuffer in
			do {
				let deletionsData = try await Data(buffer: request.body.collect(upTo: 1024 * 512))
				let deletions = try JSONDecoder().decode([DeletedRecord].self, from: deletionsData)

				var deletedIDs: [String] = []
				for deletion in deletions {
					switch deletion.type {
					case "Place": try await placeStore.delete(where: #SQL { $0.uuid == deletion.uuid })
					case "Checkin": try await checkinStore.delete(where: #SQL { $0.uuid == deletion.uuid })
					default: ()
					}

					deletedIDs.append(deletion.uuid)
					try await deletionStore.save(deletion)
				}

				let deletedIDsData = try JSONEncoder().encode(deletedIDs)
				return .init(data: deletedIDsData)
			} catch {
				print("Error handling deletions: \(error)")
				return .init()
			}
		}

		router.post("checkins") { request, context -> ByteBuffer in
			do {
				let checkinData = try await Data(buffer: request.body.collect(upTo: 1024 * 512))
				let checkins = try JSONDecoder().decode([Checkin].self, from: checkinData)

				let places = checkins.compactMap(\.place)
				for place in places {
					do {
						try await placeStore.save(ServerPlace(wrapped: place))
					} catch {
						context.logger.error("error saving place: \(error)")
					}
				}

				for checkin in checkins {
					do {
						try await checkinStore.save(ServerCheckin(wrapped: checkin))
					} catch {
						context.logger.error("error saving checkin: \(error)")
					}
				}

				context.logger.info("Synced \(places.count) places, \(checkins.count) checkins")

				return ByteBuffer(data: Data("OK".utf8))
			} catch {
				context.logger.error("Error receiving sync: \(error)")
				return ByteBuffer(data: Data(error.localizedDescription.utf8))
			}
		}

		router.get("status") { _, _ -> String in
			"wherewhen is up."
		}

		router.get("ping") { _, _ -> String in
			"PONG (\(Date()))\n"
		}

		// create application using router
		let app = Application(
			router: router,
			configuration: .init(address: .hostname("0.0.0.0", port: port)),
			eventLoopGroupProvider: .shared(eventLoopGroup)
		)

		// run hummingbird application
		try await app.runService()
	}
}
