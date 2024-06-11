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
	@State private var coordinate: Coordinate?
	@State private var isResolving = false
	@State private var results: [String: PlaceResolver.Suggestion]?

	@Environment(\.database) var database

	var body: some View {
		Section("Place Resolver Debugger") {
			TextField("Enter Latitude/Longitude", text: $coordinateString)
				.onSubmit {
					isResolving = true
				}
			Button("Resolve") {
				isResolving = true
			}
			.task(id: isResolving) {
				if coordinateString.isBlank || !isResolving {
					return
				}

				await resolve()

				isResolving = false
			}

			if let sortedResults, let coordinate {
				ForEach(sortedResults, id: \.key) { result in
					VStack(alignment: .leading, spacing: Styles.verticalSpacing) {
						HStack(spacing: 0) {
							Text("Source: ")
							Text(result.key)
								.bold()
							Spacer()
							Text("Confidence: \(result.value.confidence)")
						}
						.font(.caption)
						ManualCheckinPlaceCellView(
							currentLocation: result.value.place.coordinate,
							place: result.value.place
						)
					}
					Text("\(coordinate.latitude), \(coordinate.longitude)")
						.font(.caption)
						.foregroundStyle(.secondary)
				}
			}
		}
	}

	func resolve() async {
		guard let match = coordinateString.wholeMatch(of: #/(-?\d+\.\d+)[,\/\s]\s?(-?\d+\.\d+)/#),
		      let lat = Double(match.output.1),
		      let lng = Double(match.output.2)
		else {
			print("didn't get coords from regex")
			return
		}

		let coordinate = Coordinate(lat, lng)
		self.coordinate = coordinate
		let resolver = PlaceResolver(
			database: database,
			coordinate: coordinate
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
