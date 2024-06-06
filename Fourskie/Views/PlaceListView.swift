//
//  PlaceListView.swift
//  Fourskie
//
//  Created by Pat Nakajima on 6/5/24.
//

import Foundation
import LibFourskie
import SwiftUI
import UIKit

class PlaceListCell: UITableViewCell {
	var place: Place!

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
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

	override func scrollViewDidScroll(_: UIScrollView) {
		visiblePlacesDebouncer.debounce {
			self.visiblePlaces.wrappedValue = self.findVisiblePlaces()
		}
	}

	override func viewDidAppear(_: Bool) {
		visiblePlacesDebouncer.debounce {
			self.visiblePlaces.wrappedValue = self.findVisiblePlaces()
		}
	}

	override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
		places.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PlaceListCell

		let place = places[indexPath.row]
		cell.place = place
		cell.contentConfiguration = UIHostingConfiguration { cellBuilder(place) }

		return cell
	}

	public func findVisiblePlaces() -> [Place] {
		(tableView.visibleCells as! [PlaceListCell]).map(\.place)
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

// Wrapping UIKit here because List doesn't let us get visible rows easily
struct PlaceListView<CellView: View>: UIViewControllerRepresentable {
	var places: [Place]
	@Binding var visiblePlaces: [Place]
	@ViewBuilder var cellBuilder: (Place) -> CellView

	func makeUIViewController(context _: Context) -> PlaceListController<CellView> {
		PlaceListController(
			places: places,
			visiblePlaces: $visiblePlaces,
			cellBuilder: cellBuilder
		)
	}

	func updateUIViewController(_ uiViewController: PlaceListController<CellView>, context _: Context) {
		print("Update")
		uiViewController.places = places
		uiViewController.tableView.reloadData()
		visiblePlaces = uiViewController.findVisiblePlaces()
	}
}
