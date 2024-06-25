//
//  PlaceFormView.swift
//  WhereWhen
//
//  Created by Pat Nakajima on 6/14/24.
//

import LibWhereWhen
import Observation
import PlaceResolver
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

// I tried to name this asString as well, but it didn't work in SwiftUI
// previews for some reason?
extension Binding<Double> {
	var doubleAsString: Binding<String> {
		Binding<String>(
			get: {
				String(wrappedValue)
			},
			set: { newValue in
				wrappedValue = Double(newValue) ?? 0
			}
		)
	}
}

// I tried to name this asString as well, but it didn't work in SwiftUI
// previews for some reason?
extension Binding<Coordinate> {
	var coordinateAsString: Binding<String> {
		Binding<String>(
			get: {
				"\(wrappedValue.latitude), \(wrappedValue.longitude)"
			},
			set: { newValue in
				wrappedValue = Coordinate(string: newValue) ?? .init(0, 0)
			}
		)
	}
}

struct PlaceFormView: View {
	@Environment(\.database) var database

	@Binding var place: Place

	var buttonLabel: String
	var onComplete: () -> Void

	@State private var address: Address
	@State private var website: String

	@State private var resolvedCoordinate: Coordinate?
	@State private var isResolvingCoordinateAddress = false

	@FocusState var isFocused: Bool

	init(place: Binding<Place>, buttonLabel: String, onComplete: @escaping () -> Void) {
		self._place = place
		self.buttonLabel = buttonLabel

		let place = place.wrappedValue
		self.address = Address(place: place)
		self.website = place.url?.absoluteString ?? ""

		self.onComplete = onComplete
	}

	var body: some View {
		Form {
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
					withAnimation {
						place.coordinate = .init(place.coordinate.longitude, place.coordinate.latitude)
					}
				}
				.font(.caption)
				.textCase(.none)
			}) {
				Grid(alignment: .leading) {
					GridRow {
						Text("Coordinate:")
						FocusableTextField("Latitude, Longitude", text: $place.coordinate.coordinateAsString)
					}
				}

				Button("Refresh Details from Location") {
					isResolvingCoordinateAddress = true
				}
				.disabled(place.coordinate == resolvedCoordinate)
				.transition(.move(edge: .trailing))
				.task(id: isResolvingCoordinateAddress) {
					guard isResolvingCoordinateAddress else { return }

					let suggestedPlace = await PlaceResolver(
						database: database,
						coordinate: place.coordinate,
						distance: 100
					).bestGuessPlace()

					withAnimation {
						if let suggestedPlace {
							address = Address(place: suggestedPlace)
							place = suggestedPlace
							resolvedCoordinate = place.coordinate
						} else {
							print("No suggestion")
						}

						isResolvingCoordinateAddress = false
					}
				}
			}

			Button(buttonLabel) {
				complete()
			}
		}
		.listSectionSpacing(.compact)
	}

	var isDisabled: Bool {
		place.name.isBlank
	}

	func complete() {
		onComplete()
	}
}

#if DEBUG
	struct PlaceFormViewPreviewContainer: View {
		@State var place = Place.preview

		var body: some View {
			PreviewsWrapper {
				PlaceFormView(place: $place, buttonLabel: "Done!") {
					print("ok")
				}
			}
		}
	}

	#Preview {
		PlaceFormViewPreviewContainer()
	}
#endif
