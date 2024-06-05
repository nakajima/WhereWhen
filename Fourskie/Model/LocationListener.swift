//
//  LocationListener.swift
//  Fourskie
//
//  Created by Pat Nakajima on 6/4/24.
//

import CoreLocation
import Foundation
import Observation
import SwiftData

@Observable class LocationListener: NSObject, CLLocationManagerDelegate {
	let logger = DiskLogger(label: "Location", location: URL.documentsDirectory.appending(path: "fourskie.log"))
	let manager = CLLocationManager()

	var isAuthorized = false
	var container: ModelContainer

	init(container: ModelContainer) {
		manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
		manager.distanceFilter = kCLLocationAccuracyNearestTenMeters
		manager.allowsBackgroundLocationUpdates = true
		manager.pausesLocationUpdatesAutomatically = false

		self.container = container
		self.isAuthorized = manager.authorizationStatus != .authorizedAlways

		super.init()

		manager.delegate = self
	}

	func requestAuthorization() {
		logger.info("Requested authorization.")
		manager.requestAlwaysAuthorization()
	}

	func start() {
		manager.startMonitoringVisits()
		logger.info("Started monitoring visits. Precise: \(manager.desiredAccuracy)")
	}

	// MARK: Delegate methods

	func locationManager(_: CLLocationManager, didVisit visit: CLVisit) {
		logger.info("didVisit: \(visit.debugDescription)")
		let checkin = Checkin(visit: visit)

		Task {
			let context = ModelContext(container)
			context.insert(checkin)
			do {
				try context.save()
			} catch {
				logger.error("Error saving checking: \(error)")
			}
		}
	}

	func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
		logger.info("DidChangeAuthorization: \(manager.authorizationStatus)")
		isAuthorized = manager.authorizationStatus == .authorizedAlways

		if isAuthorized {
			start()
		}
	}
}
