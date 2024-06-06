//
//  ManualCheckinPlaceCellView.swift
//  Fourskie
//
//  Created by Pat Nakajima on 6/5/24.
//

import Foundation
import LibFourskie
import SwiftUI

struct ManualCheckinPlaceCellView: View {
	var currentLocation: Coordinate
	var place: Place

	var body: some View {
		VStack(alignment: .leading, spacing: 4) {
			Text(place.name)
				.multilineTextAlignment(.leading)
				.foregroundStyle(Color.primary)

			HStack {
				distance(to: place)

				if let category = place.category {
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
						Link(url.absoluteString, destination: url)
							.font(.caption)
							.foregroundColor(.secondary)
							.lineLimit(1)
					}
				}
			}
			.foregroundStyle(Color.secondary)
			.font(.caption)
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
