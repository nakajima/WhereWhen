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
		case authorizationNeeded, requestAlreadyInProgress, locationNotFound
	}

	class LocationRequest {
		var continuation: CheckedContinuation<CLLocation, any Swift.Error>

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
	private var locationRequest: LocationRequest?

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

		if locationRequest != nil {
			throw Error.requestAlreadyInProgress
		}

		let result = try await withCheckedThrowingContinuation { continuation in
			self.locationRequest = LocationRequest(continuation: continuation)

			manager.requestLocation()
		}

		logger.trace("Location request fulfilled with: \(result)")

		return result
	}

	// MARK: Delegate methods

	func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		if let locationRequest, let location = locations.first {
			logger.info("Location updated: \(location)")
			locationRequest.fulfill(with: .success(location))
			self.locationRequest = nil
		} else if let locationRequest {
			logger.info("Location update failed: not found")
			locationRequest.fulfill(with: .failure(Error.locationNotFound))
			self.locationRequest = nil
		}
	}

	func locationManager(_: CLLocationManager, didFailWithError error: any Swift.Error) {
		logger.info("Location request failed with: \(error)")
		if let locationRequest {
			locationRequest.fulfill(with: .failure(error))
		}
	}

	func locationManager(_: CLLocationManager, didVisit visit: CLVisit) {
		logger.info("didVisit: \(visit.debugDescription)")

		Task {
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

	func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
		logger.info("DidChangeAuthorization: \(manager.authorizationStatus)")

		Task { @MainActor in
			isAuthorized = manager.authorizationStatus == .authorizedAlways

			if isAuthorized {
				start()
			}
		}
	}
}
