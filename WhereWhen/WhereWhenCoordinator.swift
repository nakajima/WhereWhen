//
//  WhereWhenCoordinator.swift
//  WhereWhen
//
//  Created by Pat Nakajima on 6/4/24.
//

import Database
import Foundation
import LibWhereWhen
import SwiftUI

@MainActor @Observable final class WhereWhenCoordinator {
	public let logger = DiskLogger(label: "Coordinator", location: URL.documentsDirectory.appending(path: "wherewhen.log"))

	let database: DatabaseContainer

	var isShowingManualCheckin = false
	var errorMessage: String?
	var isSyncServerOnline = false
	var syncer: Syncer?

	nonisolated init(database: DatabaseContainer) {
		self.database = database
		Task { @MainActor in
			self.syncer = Syncer.load(with: database)
		}
	}

	func checkSyncServer() async {
		guard let syncer else {
			isSyncServerOnline = false
			return
		}

		isSyncServerOnline = await syncer.client.isAvailable()
	}

	func sync() {
		syncer?.sync()
	}

	func dismissError() {
		withAnimation {
			errorMessage = nil
		}
	}

	func manualCheckIn(place: Place, from coordinate: Coordinate) {
		do {
			let checkin = Checkin(
				source: .manual,
				uuid: UUID().uuidString,
				coordinate: coordinate,
				savedAt: Date(),
				accuracy: place.coordinate.distance(to: coordinate),
				arrivalDate: Date(),
				departureDate: nil,
				place: place
			)

			try checkin.save(to: database)
		} catch {
			errorMessage = error.localizedDescription
		}

		isShowingManualCheckin = false
	}
}
