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

	var body: some View {
		NavigationContainer(path: $path) {
			Map(initialPosition: .automatic) {
				UserAnnotation(anchor: .center)
				ForEach(places) { place in
					Annotation("", coordinate: place.coordinate.clLocation) {
						Button(action: {
							path.append(.place(place))
						}) {
							VStack {
								Image(systemName: "mappin.circle.fill")
									.resizable()
									.scaledToFit()
									.frame(width: 24, height: 24)
									.foregroundStyle(.white, .blue)
									.shadow(radius: 2)
								Text(place.name)
									.font(.caption)
									.bold()
									.foregroundColor(.primary)
									.shadow(color: Color(UIColor.systemBackground).opacity(1), radius: 2)
							}
						}
					}
				}
			}
		}
	}
}

#if DEBUG
#Preview {
	HomeMapView()
		.onAppear {
			try! Checkin.preview.save(to: .memory)
		}
}
#endif
