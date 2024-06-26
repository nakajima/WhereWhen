//
//  HomeMapView.swift
//  WhereWhen
//
//  Created by Pat Nakajima on 6/20/24.
//

import Database
import GRDBQuery
import LibWhereWhen
import MapKit
import SwiftUI

struct HomeMapView: View {
	@Query(ListQueryRequest<Place>()) var places: [Place]
	@State private var path: [Route] = []
	@State private var position: MapCameraPosition

	init() {
		self._places = Query(ListQueryRequest<Place>())
		self._path = State(wrappedValue: [])
		self._position = .init(wrappedValue: .automatic)
	}

	var body: some View {
		NavigationContainer(path: $path) {
			Map(position: $position) {
				UserAnnotation(anchor: .center)
				ForEach(places) { place in
					Annotation(place.name, coordinate: place.coordinate.clLocation) {
						Button(action: {
							path.append(.place(place))
						}) {
							VStack {
								Image(systemName: "mappin.circle.fill")
									.resizable()
									.scaledToFit()
									.frame(width: 24, height: 24)
									.foregroundStyle(.white, .pink)
									.shadow(radius: 2)
							}
						}
					}
					.annotationTitles(.automatic)
				}
			}
		}
	}
}

#if DEBUG
	#Preview {
		HomeMapView()
			.onAppear {
				let placesJSON = #"""
				[]
				"""#

				let decoder = JSONDecoder()
				decoder.dateDecodingStrategy = .iso8601
				let places = try! decoder.decode([Place].self, from: Data(placesJSON.utf8))
				for place in places {
					try! place.save(to: .memory)
				}
			}
	}
#endif
