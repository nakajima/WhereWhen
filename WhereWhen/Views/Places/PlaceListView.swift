//
//  PlaceListView.swift
//  WhereWhen
//
//  Created by Pat Nakajima on 6/5/24.
//

import Foundation
import LibWhereWhen
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

@MainActor class PlaceListController<CellView: View, LoadMoreView: View>: UITableViewController {
	var places: [Place]
	var visiblePlacesChanged: (([Place]) -> Void)?
	var cellBuilder: (Place) -> CellView
	var loadMore: (() -> LoadMoreView)?

	let visiblePlacesDebouncer = Debouncer()

	init(
		places: [Place],
		visiblePlacesChanged: (([Place]) -> Void)?,
		@ViewBuilder cellBuilder: @escaping (Place) -> CellView,
		loadMore: (() -> LoadMoreView)?
	) {
		self.places = places
		self.visiblePlacesChanged = visiblePlacesChanged
		self.cellBuilder = cellBuilder
		self.loadMore = loadMore

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
		places.count + 1
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PlaceListCell

		if places.indices.contains(indexPath.row) {
			let place = places[indexPath.row]
			cell.place = place
			cell.contentConfiguration = UIHostingConfiguration { cellBuilder(place) }
		} else {
			if let loadMore {
				cell.contentConfiguration = UIHostingConfiguration { loadMore() }
			}
		}

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
struct PlaceListView<CellView: View, LoadMoreView: View>: UIViewControllerRepresentable {
	var places: [Place]
	var visiblePlacesChanged: (([Place]) -> Void)?
	@ViewBuilder var cellBuilder: (Place) -> CellView
	var loadMore: (() -> LoadMoreView)?

	func makeUIViewController(context _: Context) -> PlaceListController<CellView, LoadMoreView> {
		PlaceListController(
			places: places,
			visiblePlacesChanged: visiblePlacesChanged,
			cellBuilder: cellBuilder,
			loadMore: loadMore
		)
	}

	func updateUIViewController(_ uiViewController: PlaceListController<CellView, LoadMoreView>, context _: Context) {
		print("Updating view controller")
		uiViewController.places = places
		uiViewController.tableView.reloadData()
		uiViewController.refreshVisiblePlaces()
	}
}
