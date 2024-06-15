//
//  Syncer.swift
//  WhereWhen
//
//  Created by Pat Nakajima on 6/6/24.
//

import Database
import Foundation
import GRDB
import LibWhereWhen
import Queue

actor Syncer {
	let database: DatabaseContainer
	let client: WhereWhenClient
	let queue: AsyncQueue
	let logger = DiskLogger(label: "Syncer", location: URL.documentsDirectory.appending(path: "WhereWhen.log"))

	nonisolated let clientURL: URL

	nonisolated static func load(with database: DatabaseContainer) -> Syncer? {
		if let savedURL = UserDefaults.standard.string(forKey: "syncURL"),
		   let url = URL(string: savedURL)
		{
			return Syncer(database: database, client: WhereWhenClient(serverURL: url))
		}

		return nil
	}

	init(database: DatabaseContainer, client: WhereWhenClient) {
		self.database = database
		self.client = client
		self.clientURL = client.serverURL
		self.queue = AsyncQueue()
	}

	nonisolated func teardown() {
		UserDefaults.standard.removeObject(forKey: "syncURL")
	}

	nonisolated func setup() {
		UserDefaults.standard.set(client.serverURL.absoluteString, forKey: "syncURL")
		sync()
	}

	func syncDeletions() async {
		do {
			let deletions = try await DeletedRecord.all(in: database)
			let deletedIDs = try await client.upload(deletions: deletions)

			_ = try await database.write { db in
				try DeletedRecord.deleteAll(db, keys: deletedIDs)
			}

			await logger.info("Uploaded \(deletions.count) deletions, received \(deletedIDs.count) deleted ids")
		} catch {
			await logger.error("Error syncing deletions: \(error)")
		}
	}

	func upload() async {
		do {
//			let lastSyncedAt = await client.lastSyncedAt()
			let localCheckins = try await database.read { db in
				try Checkin
//					.filter(Column("savedAt") > lastSyncedAt)
					.including(optional: Checkin.placeAssociation)
					.fetchAll(db)
			}

			if localCheckins.isEmpty {
				await logger.info("No local checkins to report")
				return
			}

			try await client.upload(checkins: localCheckins)
			await logger.info("Uploaded \(localCheckins.count)")
		} catch {
			await logger.error("Error uploading: \(error)")
		}
	}

	func download() async {
		do {
			let lastCheckinAt = try await database.read { db in
				try Checkin.order(Column("savedAt").desc).fetchOne(db)?.savedAt ?? .distantPast
			}

			let checkins = try await client.download(since: lastCheckinAt)

			for checkin in checkins {
				if let place = checkin.place {
					try await place.save(to: database)
				}

				try await checkin.save(to: database)
			}

			await logger.info("Imported \(checkins.count) checkins")
		} catch {
			await logger.error("Error downloading: \(error) \(database._queue.path)")
		}
	}

	nonisolated func sync() {
		queue.addOperation {
			await self.synchronize()
		}
	}

	private func synchronize() async {
		guard await client.isAvailable() else {
			await logger.error("Sync server unavailable")
			return
		}

		await syncDeletions()
		await upload()
		await download()
	}
}
