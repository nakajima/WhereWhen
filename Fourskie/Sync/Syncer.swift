//
//  Syncer.swift
//  Fourskie
//
//  Created by Pat Nakajima on 6/6/24.
//

import Foundation
import LibFourskie
import SwiftData
import Queue

actor Syncer {
	let container: ModelContainer
	let client: FourskieClient
	let queue: AsyncQueue
	let logger = DiskLogger(label: "Syncer", location: URL.documentsDirectory.appending(path: "fourskie.log"))

	init(container: ModelContainer, client: FourskieClient) {
		self.container = container
		self.client = client
		self.queue = AsyncQueue()
	}

	func upload() async {
		do {
			let context = ModelContext(container)
			let lastSyncedAt = await client.lastSyncedAt()
			let localCheckins = try context.all(where: #Predicate<LocalCheckin> { $0.savedAt > lastSyncedAt })
			let checkins = localCheckins.map(\.wrapped)

			if localCheckins.isEmpty {
				logger.info("No local checkins to report")
				return
			}

			try await client.upload(checkins: checkins)
		} catch {
			logger.error("Error uploading: \(error)")
		}
	}

	func download() async {
		do {
			let context = ModelContext(container)
			let lastCheckinAt = try context.first(sort: [SortDescriptor(\LocalCheckin.savedAt, order: .reverse)])?.savedAt ?? .distantPast
			let checkins = try await client.download(since: lastCheckinAt)

			for checkin in checkins {
				let place: LocalPlace? = if let place = checkin.place {
					LocalPlace.model(for: place, in: context)
				} else {
					nil
				}

				if let place {
					context.insert(place)
				}

				let localCheckin = LocalCheckin.model(for: checkin, in: context)
				context.insert(localCheckin)

				localCheckin.place = place
			}

			try context.save()
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
			self.logger.error("Sync server unavailable")
			return
		}

		await upload()
		await download()
	}
}
