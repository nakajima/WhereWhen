//
//  MapThumbnail.swift
//  WhereWhen
//
//  Created by Pat Nakajima on 6/11/24.
//

import LibWhereWhen
@preconcurrency import MapKit
import Nuke
import NukeUI
import SwiftUI

// MapKit maps are like 50 megs of ram so let's
// just generate images and show those when we can.
@MainActor struct MapThumbnail: View {
	let coordinate: Coordinate
	let span: MKCoordinateSpan

	@State private var status: Status = .loading

	enum Status {
		case loading, loaded(Image), error(String)
	}

	init(region: MKCoordinateRegion) {
		self.coordinate = .init(region.center)
		self.span = region.span
	}

	init(coordinate: Coordinate, span: MKCoordinateSpan) {
		self.coordinate = coordinate
		self.span = span
	}

	var body: some View {
		switch status {
		case .loading:
			GeometryReader { geo in
				Color.secondary
					.task {
						do {
							try await generate(size: geo.size)
						} catch {
							self.status = .error(error.localizedDescription)
						}
					}
			}
		case let .loaded(image):
			image
				.resizable()
				.scaledToFill()
		case .error:
			Map(initialPosition: .region(region))
		}
	}

	private var region: MKCoordinateRegion {
		MKCoordinateRegion(
			center: coordinate.clLocation,
			span: span
		)
	}

	private func generate(size: CGSize) async throws {
		do {
			let image = try await ImagePipeline.shared.image(for: coordinate.cacheURL(for: size))

			print("Using cached thumbnail")

			status = .loaded(Image(uiImage: image))
		} catch {
			print(error)
		}

		let options: MKMapSnapshotter.Options = .init()
		options.region = region

		options.size = size
		options.mapType = .standard
		options.showsBuildings = true

		let snapshotter = MKMapSnapshotter(
			options: options
		)

		let snapshot = try await snapshotter.start()
		let data = snapshot.image.pngData()

		if let data {
			do {
				try data.write(to: coordinate.cacheURL(for: size))
			} catch {
				status = .error(error.localizedDescription)
			}

			withAnimation {
				self.status = .loaded(Image(uiImage: snapshot.image))
			}
		}
	}
}

private extension Coordinate {
	func cacheURL(for size: CGSize) -> URL {
		let coords = "\(latitude)-\(longitude)"
			.components(separatedBy: ".")
			.joined(separator: "-")

		return URL.temporaryDirectory.appending(path: "\(coords)-\(size.width)x\(size.height).png")
	}
}

#if DEBUG
	#Preview {
		let coordinate = Coordinate(
			37.32433196872691, -122.03635318945706
		)

		return VStack {
			MapThumbnail(
				coordinate: coordinate,
				span: .within(meters: 200)
			)
			.frame(width: 200, height: 200)

			Button("Clear Cache") {
				try! FileManager.default.removeItem(at: coordinate.cacheURL(for: .init(width: 200, height: 200)))
			}
		}
	}
#endif
