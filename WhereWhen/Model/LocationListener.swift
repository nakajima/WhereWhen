//
//  LocationListener.swift
//  WhereWhen
//
//  Created by Pat Nakajima on 6/4/24.
//

@preconcurrency import CoreLocation
import Database
import Foundation
import LibWhereWhen
import Observation
import PlaceResolver

@MainActor @Observable final class LocationListener: NSObject, Sendable, CLLocationManagerDelegate {
	enum Error: Swift.Error {
		case authorizationNeeded, locationNotFound
	}

	final class LocationRequest: Sendable {
		let continuation: CheckedContinuation<CLLocation, any Swift.Error>

		init(continuation: CheckedContinuation<CLLocation, any Swift.Error>) {
			self.continuation = continuation
		}

		func fulfill(with result: Result<CLLocation, any Swift.Error>) {
			continuation.resume(with: result)
		}
	}

	let logger = DiskLogger(label: "Location", location: URL.documentsDirectory.appending(path: "wherewhen.log"))
	let manager = CLLocationManager()

	var isAuthorized = false
	var database: DatabaseContainer
	private var locationRequests: [LocationRequest] = []

	@MainActor init(database: DatabaseContainer) {
		manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
		manager.distanceFilter = kCLLocationAccuracyHundredMeters
		manager.allowsBackgroundLocationUpdates = true
		manager.pausesLocationUpdatesAutomatically = false

		self.database = database
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

	func requestCurrent() async throws -> CLLocation {
		logger.info("Requesting current location.")

		let result = try await withCheckedThrowingContinuation { [weak self] continuation in
			guard let self else { return }
			locationRequests.append(LocationRequest(continuation: continuation))
			manager.requestLocation()
		}

		logger.trace("Location request fulfilled with: \(result)")

		return result
	}

	// MARK: Delegate methods

	nonisolated func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		Task { @MainActor in
			while let locationRequest = locationRequests.popLast() {
				if let location = locations.first {
					logger.info("Location updated: \(location)")
					locationRequest.fulfill(with: .success(location))
				} else {
					logger.info("Location update failed: not found")
					locationRequest.fulfill(with: .failure(Error.locationNotFound))
				}
			}
		}
	}

	@MainActor func clearLocationRequest() {
		locationRequests.removeAll()
	}

	nonisolated func locationManager(_: CLLocationManager, didFailWithError error: any Swift.Error) {
		Task { @MainActor in
			logger.info("Location request failed with: \(error)")
			while let locationRequest = locationRequests.popLast() {
				locationRequest.fulfill(with: .failure(error))
			}
		}
	}

	nonisolated func locationManager(_: CLLocationManager, didVisit visit: CLVisit) {
		Task { @MainActor in
			do {
				let log = URL.documentsDirectory.appending(path: "visits.log")
				let line = VisitImporter.Line(
					latitude: visit.coordinate.latitude,
					longitude: visit.coordinate.longitude,
					timestamp: Date()
				)

				try Data(line.description.utf8).append(to: log)
			} catch {
				logger.error("Error logging checkin: \(error)")
			}

			logger.info("didVisit: \(visit.debugDescription)")

			do {
				let place = await PlaceResolver(
					database: database,
					coordinate: .init(visit.coordinate)
				).bestGuessPlace()

				try await CheckinCreator(
					checkin: Checkin(visit: visit),
					database: database
				).create(place: place)
			} catch {
				logger.error("Error saving checking: \(error)")
			}
		}
	}

	nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
		Task { @MainActor in
			logger.info("DidChangeAuthorization: \(manager.authorizationStatus)")

			isAuthorized = manager.authorizationStatus == .authorizedAlways

			if isAuthorized {
				start()
			}
		}
	}
}
