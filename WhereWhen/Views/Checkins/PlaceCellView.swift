//
//  PlaceCellView.swift
//  WhereWhen
//
//  Created by Pat Nakajima on 6/5/24.
//

import Foundation
import GRDB
import LibWhereWhen
import SwiftUI

struct PlaceCellView: View {
	@Environment(\.database) var database
	var currentLocation: Coordinate
	var place: Place

	var body: some View {
		VStack(alignment: .leading, spacing: 4) {
			Text(place.name)
				.multilineTextAlignment(.leading)
				.foregroundStyle(Color.primary)

			HStack(alignment: .top) {
				distance(to: place)

				if let category = place.category, category != .unknown {
					HStack(spacing: 2) {
						Image(systemName: "binoculars.fill")
							.foregroundStyle(.quaternary)
							.accessibilityHidden(true)
						Text(category.description)
					}
				}

				if let url = place.url {
					HStack(spacing: 2) {
						Image(systemName: "link")
							.foregroundStyle(.quaternary)
							.accessibilityHidden(true)
						Link("Website", destination: url)
							.font(.caption)
							.foregroundColor(.secondary)
							.lineLimit(1)
					}
				}

				Spacer()

				if let attribution = place.attribution {
					HStack(spacing: 2) {
						Text("Source: \(attribution)")
							.lineLimit(1)
					}
				}
			}
			.foregroundStyle(Color.secondary)
			.font(.caption)

			if let checkinCount, checkinCount > 0 {
				Text("You’ve checked-in here \(checkinCount.ordinalize("time")).")
					.font(.subheadline)
					.foregroundStyle(.primary)
			}
		}
	}

	var checkinCount: Int? {
		do {
			return try Checkin.count(in: database, where: Column("placeID") == place.uuid)
		} catch {
			return nil
		}
	}

	func distance(to result: Place) -> some View {
		let meters = result.coordinate.distance(to: currentLocation)
		let distanceInMeters = Measurement(value: meters, unit: UnitLength.meters)

		let formatter = MeasurementFormatter()
		formatter.unitOptions = .providedUnit // Use the unit we specified
		formatter.unitStyle = .long // You can also use .short or .medium

		let distance: Measurement<UnitLength>
		if meters > 200 {
			formatter.numberFormatter.maximumFractionDigits = 1
			distance = distanceInMeters.converted(to: .miles)
		} else {
			formatter.numberFormatter.maximumFractionDigits = 0
			distance = distanceInMeters.converted(to: .feet)
		}

		let formattedDistance = formatter.string(from: distance)
		let icon = Image(systemName: "mappin.circle.fill")
			.foregroundStyle(.quaternary)
			.accessibilityHidden(true)

		return HStack(spacing: 2) {
			icon
			Text(formattedDistance)
		}
	}
}
