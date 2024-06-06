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
	var visiblePlacesChanged: (([Place]) -> Void)?
	var cellBuilder: (Place) -> CellView

	let visiblePlacesDebouncer = Debouncer()

	init(
		places: [Place],
		visiblePlacesChanged: (([Place]) -> Void)?,
		@ViewBuilder cellBuilder: @escaping (Place) -> CellView
	) {
		self.places = places
		self.visiblePlacesChanged = visiblePlacesChanged
		self.cellBuilder = cellBuilder

		super.init(style: .plain)

		tableView.register(PlaceListCell.self, forCellReuseIdentifier: "cell")
		tableView.allowsSelection = false
	}

	override func scrollViewDidScroll(_: UIScrollView) {
		refreshVisiblePlaces()
	}

	override func viewDidAppear(_: Bool) {
		refreshVisiblePlaces()
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

	public func refreshVisiblePlaces() {
		visiblePlacesDebouncer.debounce {
			guard let paths = self.tableView.indexPathsForVisibleRows else {
				return
			}

			let indices = paths.map(\.row)

			guard let first = indices.first, let last = indices.last, first != last else {
				return
			}

			self.visiblePlacesChanged?(Array(self.places[first ..< last]))
		}
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

// Wrapping UIKit here because List doesn't let us get visible rows easily
struct PlaceListView<CellView: View>: UIViewControllerRepresentable {
	var places: [Place]
	var regionID: String
	var visiblePlacesChanged: (([Place]) -> Void)?
	@ViewBuilder var cellBuilder: (Place) -> CellView

	func makeUIViewController(context _: Context) -> PlaceListController<CellView> {
		PlaceListController(
			places: places,
			visiblePlacesChanged: visiblePlacesChanged,
			cellBuilder: cellBuilder
		)
	}

	func updateUIViewController(_ uiViewController: PlaceListController<CellView>, context _: Context) {
		print("Updating view controller")
		uiViewController.places = places
		uiViewController.tableView.reloadData()
		uiViewController.refreshVisiblePlaces()
	}
}
