//
//  VisitImporterLineCellView.swift
//  WhereWhen
//
//  Created by Pat Nakajima on 6/11/24.
//

import Database
import LibWhereWhen
import MapKit
import PlaceResolver
import SwiftUI

struct VisitImporterLineCellView: View {
	let line: VisitImporter.Line

	@State private var limit = 5
	@State private var cachedSuggestions: [PlaceResolver.Suggestion] = []
	@State private var status: Status = .loading
	@Environment(\.database) var database

	enum Status {
		case loading,
		     loaded([PlaceResolver.Suggestion]),
		     error(String),
		     done(Place)
	}

	var body: some View {
		Section {
			MapThumbnail(
				coordinate: line.coordinate,
				span: .within(meters: 200)
			)
			.overlay {
				Label("You were here", systemImage: "mappin")
					.labelStyle(.iconOnly)
					.foregroundStyle(.red)
			}
			.frame(height: 200)
			.listRowInsets(.init())

			VStack(alignment: .leading) {
				Text("\(line.timestamp.formatted())")
				Text("\(line.latitude), \(line.longitude)")
					.foregroundStyle(.secondary)
					.font(.caption)
			}

			switch status {
			case .loading:
				HStack {
					Text("Loading possible places…")
						.foregroundStyle(.secondary)
					Spacer()
					ProgressView()
				}
				.task {
					let placeResolver = PlaceResolver(database: database, coordinate: line.coordinate, distance: 100)
					let suggestions = await placeResolver.suggestions()
					self.status = .loaded(suggestions)
				}
			case let .loaded(results):
				ForEach(results.first(limit)) { suggestion in
					VStack(alignment: .leading, spacing: Styles.verticalSpacing) {
						HStack(spacing: 0) {
							Text("Source: ")
							Text(suggestion.source)
								.bold()
							Spacer()
							Text("Confidence: \(suggestion.confidence)")
						}
						.font(.caption)

						PlaceCellView(
							currentLocation: suggestion.place.coordinate,
							place: suggestion.place
						)

						HStack {
							Button("Import") {
								self.choose(suggestion: suggestion)
							}
							.controlSize(.mini)
							.buttonStyle(.bordered)
						}
					}
				}

				if limit < results.count {
					Button("Show More…") {
						withAnimation {
							limit += 5
						}
					}
				}
			case let .error(err):
				Text("Error: \(err)")
			case let .done(place):
				PlaceCellView(
					currentLocation: line.coordinate,
					place: place
				)
			}
		}
	}

	func choose(suggestion: PlaceResolver.Suggestion) {
		let checkin = Checkin(
			source: .manual,
			uuid: UUID().uuidString,
			coordinate: line.coordinate,
			savedAt: line.timestamp,
			accuracy: line.coordinate.distance(to: suggestion.place.coordinate),
			arrivalDate: nil,
			departureDate: nil,
			place: suggestion.place
		)

		do {
			try checkin.save(to: database)
			withAnimation {
				self.status = .done(suggestion.place)
			}
		} catch {
			withAnimation {
				self.status = .error(error.localizedDescription)
			}
		}
	}
}

#if DEBUG
	// This preview crashes the compiler for some reason???????
	#Preview {
		PreviewsWrapper {
			List {
				VisitImporterLineCellView(
					line: VisitImporter(from: "+37.38842479|-122.03036462|2024-06-11T20:03:10Z").lines[0]
				)
			}
		}
	}
#endif
