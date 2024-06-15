//
//  IgnoredPlacesListView.swift
//  WhereWhen
//
//  Created by Pat Nakajima on 6/8/24.
//

import GRDB
import GRDBQuery
import LibWhereWhen
import SwiftUI

struct IgnoredPlacesListView: View {
	@Query(IgnoredPlacesRequest()) var places: [Place]

	var body: some View {
		List {
			if places.isEmpty {
				ContentUnavailableView("No ignored places.", systemImage: "")
			}

			ForEach(places) { place in
				PlaceCellView(currentLocation: place.coordinate, place: place)
			}
		}
	}
}

#if DEBUG
	#Preview {
		PreviewsWrapper {
			IgnoredPlacesListView()
		}
	}
#endif
