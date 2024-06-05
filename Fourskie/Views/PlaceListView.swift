//
//  PlaceListView.swift
//  Fourskie
//
//  Created by Pat Nakajima on 6/5/24.
//

import Foundation
import UIKit
import SwiftUI
import LibFourskie

class PlaceListCell: UITableViewCell {
	var place: Place!

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

@MainActor class PlaceListController<CellView: View>: UITableViewController {
	var places: [Place]
	var visiblePlaces: Binding<[Place]>
	let visiblePlacesDebouncer = Debouncer()
	var cellBuilder: (Place) -> CellView

	init(places: [Place], visiblePlaces: Binding<[Place]>, @ViewBuilder cellBuilder: @escaping (Place) -> CellView) {
		self.places = places
		self.visiblePlaces = visiblePlaces
		self.cellBuilder = cellBuilder

		super.init(style: .plain)

		tableView.register(PlaceListCell.self, forCellReuseIdentifier: "cell")
		tableView.allowsSelection = false
	}

	override func scrollViewDidScroll(_ scrollView: UIScrollView) {
		visiblePlacesDebouncer.debounce {
			self.visiblePlaces.wrappedValue = (self.tableView.visibleCells as! [PlaceListCell]).map(\.place)
		}
	}

	override func viewDidAppear(_ animated: Bool) {
		self.visiblePlaces.wrappedValue = (self.tableView.visibleCells as! [PlaceListCell]).map(\.place)
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		places.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PlaceListCell

		let place = places[indexPath.row]
		cell.place = place
		cell.contentConfiguration = UIHostingConfiguration { cellBuilder(place) }

		return cell
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

// Wrapping UIKit here because List doesn't let us get visible rows easily
struct PlaceListView<CellView: View>: UIViewControllerRepresentable {
	var places: [Place]
	@Binding var visiblePlaces: [Place]
	@ViewBuilder var cellBuilder: (Place) -> CellView

	func makeUIViewController(context: Context) -> PlaceListController<CellView> {
		PlaceListController(places: places, visiblePlaces: $visiblePlaces, cellBuilder: cellBuilder)
	}

	func updateUIViewController(_ uiViewController: PlaceListController<CellView>, context: Context) {

	}
}
