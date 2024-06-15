//
//  PlaceFormView.swift
//  WhereWhen
//
//  Created by Pat Nakajima on 6/14/24.
//

import LibWhereWhen
import Observation
import SwiftUI

struct FocusableTextField: View {
	var label: String
	@Binding var text: String

	@FocusState var isFocused: Bool

	init(_ label: String, text: Binding<String>) {
		self.label = label
		self._text = text
	}

	var body: some View {
		TextField(label, text: $text)
			.focused($isFocused)
			.foregroundStyle(isFocused ? .primary : .secondary)
	}
}

extension Binding<String?> {
	var asString: Binding<String> {
		Binding<String>(
			get: {
				wrappedValue ?? ""
			},
			set: { newValue in
				wrappedValue = newValue.presence
			}
		)
	}
}

struct PlaceFormView: View {
	@Binding var place: Place

	var buttonLabel: String
	var onComplete: () -> Void

	@State private var address: Address
	@State private var website: String

	@State private var latitude: String = ""
	@State private var longitude: String = ""

	@FocusState var isFocused: Bool

	init(place: Binding<Place>, buttonLabel: String, onComplete: @escaping () -> Void) {
		self._place = place
		self.buttonLabel = buttonLabel

		let place = place.wrappedValue
		self.address = Address(place: place)
		self.website = place.url?.absoluteString ?? ""

		self.latitude = String(place.coordinate.latitude)
		self.longitude = String(place.coordinate.longitude)

		self.onComplete = onComplete
	}

	var body: some View {
		Section {
			TextField("Place Name", text: $place.name)
				.onChange(of: $place.name.wrappedValue) {
					print("new name from form: \($place.name.wrappedValue)")
				}
			Picker(selection: $place.category) {
				Text("None")
					.tag(nil as String?)
				ForEach(PlaceCategory.allCases, id: \.rawValue) { category in
					Text(category.description)
						.tag(category.description)
				}
			} label: {
				Text("Category \(Text("(optional)").foregroundStyle(.secondary))")
			}
		}

		Section("Address") {
			TextField("Street", text: $address.street)
			HStack {
				TextField("City", text: $address.locality)
					.frame(maxWidth: .infinity)
				TextField("State", text: $address.administrativeArea)
					.frame(maxWidth: 64)
				TextField("Postal Code", text: $address.postalCode)
					.frame(maxWidth: 96)
			}
		}

		Grid(alignment: .leading) {
			GridRow {
				Text("Phone Number:")
				FocusableTextField("Phone Number", text: $place.phoneNumber.asString)
			}
			Divider()
			GridRow {
				Text("Website:")
				FocusableTextField("URL", text: $website)
			}
		}

		Section(header: HStack {
			Text("GPS")
			Spacer()
			Button("Swap") {
				let oldLatitude = latitude
				self.latitude = longitude
				self.longitude = oldLatitude
			}
			.font(.caption)
			.textCase(.none)
		}) {
			Grid(alignment: .leading) {
				GridRow {
					Text("Latitude:")
					FocusableTextField("Latitude", text: $latitude)
				}
				Divider()
				GridRow {
					Text("Longitude:")
					FocusableTextField("Longitude", text: $longitude)
				}
			}
			.onChange(of: place.coordinate) {
				latitude = String(place.coordinate.latitude)
				longitude = String(place.coordinate.longitude)
			}
			.onChange(of: [latitude, longitude]) {
				place.coordinate = if let lat = Double(latitude), let lon = Double(longitude) {
					Coordinate(lat, lon)
				} else {
					self.place.coordinate
				}
			}
		}

		Button(buttonLabel) {
			complete()
		}
	}

	var isDisabled: Bool {
		place.name.isBlank
	}

	func complete() {
		onComplete()
	}
}

#if DEBUG
	#Preview {
		NavigationStack {
			Form {
				PlaceFormView(place: .constant(Place.preview), buttonLabel: "Done!") {
					print("ok")
				}
			}
		}
	}
#endif
