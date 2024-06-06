//
//  LocationListener.swift
//  Fourskie
//
//  Created by Pat Nakajima on 6/4/24.
//

@preconcurrency import CoreLocation
import Foundation
import Observation
import SwiftData

@Observable class LocationListener: NSObject, CLLocationManagerDelegate {
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

	let logger = DiskLogger(label: "Location", location: URL.documentsDirectory.appending(path: "fourskie.log"))
	let manager = CLLocationManager()

	var isAuthorized = false
	var container: ModelContainer
	var locationRequest: LocationRequest?

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

		// Assigning these to locals for sendability
		let container = self.container
		let logger = self.logger

		Task {
			do {
				let context = ModelContext(container)

				let checkin = LocalCheckin(visit: visit)
				context.insert(checkin)

				if let place = try await PlaceFinder(
					container: container,
					coordinate: .init(visit.coordinate)
				).results(in: .init(center: visit.coordinate, span: .within(meters: 10))).first {
					let localPlace = LocalPlace(wrapped: place)
					context.insert(localPlace)
					checkin.place = localPlace
				}

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
