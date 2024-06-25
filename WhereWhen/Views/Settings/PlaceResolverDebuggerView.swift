//
//  PlaceResolverDebuggerView.swift
//  WhereWhen
//
//  Created by Pat Nakajima on 6/10/24.
//

import LibWhereWhen
import PlaceResolver
import SwiftUI

@MainActor struct PlaceResolverDebuggerView: View {
	@State private var coordinateString = ""
//	@State private var coordinate: Coordinate?
	@State private var isResolving = false
	@State private var isLocating = false
	@State private var results: [String: PlaceResolver.Suggestion]?

	@Environment(LocationListener.self) var location
	@Environment(\.database) var database

	var body: some View {
		Section("Place Resolver Debugger") {
			TextField("Enter Latitude/Longitude", text: $coordinateString)
				.onSubmit {
					isResolving = true
				}
			Button(action: {
				isResolving = true
			}) {
				Text("Resolve Coordinate")
					.frame(maxWidth: .infinity, alignment: .leading)
			}
			.disabled(coordinate == nil || isResolving)
			.overlay(alignment: .trailing) {
				if isResolving {
					ProgressView()
				}
			}
			.task(id: isResolving) {
				if coordinateString.isBlank || !isResolving {
					return
				}

				await resolve()

				isResolving = false
			}
			Button(action: {
				isLocating = true
			}) {
				Text("Locate Me")
					.frame(maxWidth: .infinity, alignment: .leading)
			}
			.overlay(alignment: .trailing) {
				if isLocating {
					ProgressView()
				}
			}
			.disabled(isLocating)
			.task(id: isLocating) {
				guard isLocating else { return }

				do {
					let current = try await location.requestCurrent()
					coordinateString = "\(current.coordinate.latitude), \(current.coordinate.longitude)"
				} catch {
					print("error locating: \(error)")
				}

				isLocating = false
			}

			if let sortedResults, let coordinate {
				ForEach(sortedResults, id: \.key) { result in
					VStack(alignment: .leading, spacing: Styles.verticalSpacing) {
						HStack(spacing: 0) {
							Text("Source: ")
							Text(result.key)
								.bold()
							Spacer()
							Text("Confidence: \(result.value.confidence, format: .number)")
						}
						.font(.caption)
						PlaceCellView(
							currentLocation: result.value.place.coordinate,
							place: result.value.place
						)

						Text("\(coordinate.latitude), \(coordinate.longitude)")
							.font(.caption)
							.foregroundStyle(.secondary)
					}
				}
			}
		}
	}

	var coordinate: Coordinate? {
		Coordinate(string: coordinateString)
	}

	func resolve() async {
		guard let coordinate else {
			print("did not parse coordinate")
			return
		}

		let resolver = PlaceResolver(
			database: database,
			coordinate: coordinate,
			distance: 100
		)

		let suggestions = await resolver.suggestions()
		results = suggestions.reduce(into: [:]) { res, suggestion in
			res[suggestion.source] = suggestion
		}
	}

	var sortedResults: [(key: String, value: PlaceResolver.Suggestion)]? {
		guard let results else {
			return nil
		}

		return results.sorted {
			$0.value.confidence > $1.value.confidence
		}
	}
}

#if DEBUG
	#Preview {
		PreviewsWrapper {
			List {
				PlaceResolverDebuggerView()
			}
		}
	}
#endif
