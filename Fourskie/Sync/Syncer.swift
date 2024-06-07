//
//  Syncer.swift
//  Fourskie
//
//  Created by Pat Nakajima on 6/6/24.
//

import Foundation
import GRDB
import LibFourskie
import Queue

actor Syncer {
	let database: Database
	let client: FourskieClient
	let queue: AsyncQueue
	let logger = DiskLogger(label: "Syncer", location: URL.documentsDirectory.appending(path: "fourskie.log"))

	init(database: Database, client: FourskieClient) {
		self.database = database
		self.client = client
		self.queue = AsyncQueue()
	}

	func upload() async {
		do {
			let lastSyncedAt = await client.lastSyncedAt()
			let localCheckins = try await database.queue.read { db in
				try Checkin
					.filter(Column("savedAt") > lastSyncedAt)
					.including(optional: Checkin.placeAssociation)
					.fetchAll(db)
			}

			if localCheckins.isEmpty {
				logger.info("No local checkins to report")
				return
			}

			try await client.upload(checkins: localCheckins)
		} catch {
			logger.error("Error uploading: \(error)")
		}
	}

	func download() async {
		do {
			let lastCheckinAt = try await database.queue.read { db in
				try Checkin.order(Column("savedAt").desc).fetchOne(db)?.savedAt ?? .distantPast
			}

			let checkins = try await client.download(since: lastCheckinAt)

			for checkin in checkins {
				if let place = checkin.place {
					try await database.queue.write { db in
						try place.save(db)
					}
				}

				try await database.queue.write { db in
					try checkin.save(db)
				}
			}
		} catch {
			logger.error("Error downloading: \(error)")
		}
	}

	nonisolated func sync() {
		queue.addOperation {
			await self.synchronize()
		}
	}

	private func synchronize() async {
		guard await client.isAvailable() else {
			logger.error("Sync server unavailable")
			return
		}

		await upload()
		await download()
	}
}
