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
import Queue
import SwiftUI

private let logger = DiskLogger(label: "MapThumbnail", location: URL.documentsDirectory.appending(path: "wherewhen.log"))

enum MapThumbnailError: Error {
	case snapshotNotGenerated, invalidCoordinate
}

// MapKit maps are like 50 megs of ram so let's
// just generate images and show those when we can.
@MainActor struct MapThumbnail: View {
	static let queue = AsyncQueue()

	let coordinate: Coordinate
	let span: MKCoordinateSpan

	@State private var status: Status = .loading
	@Environment(\.colorScheme) var colorScheme

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
		GeometryReader { geo in
			switch status {
			case .loading:
				Color.secondary
					.task {
						do {
							try await load(size: geo.size, colorScheme: colorScheme)
						} catch {
							self.status = .error(error.localizedDescription)
						}
					}
			case let .loaded(image):
				image
					.resizable()
					.scaledToFill()
					.onChange(of: colorScheme) {
						Task {
							try await load(size: geo.size, colorScheme: colorScheme)
						}
					}
			case .error:
				Map(initialPosition: .region(region))
			}
		}
	}

	private var region: MKCoordinateRegion {
		MKCoordinateRegion(
			center: coordinate.clLocation,
			span: span
		)
	}

	private func load(size: CGSize, colorScheme: ColorScheme) async throws {
		Self.queue.addOperation {
			do {
				let image = try await ImagePipeline.shared.image(for: coordinate.cacheURL(for: size, span: span, colorScheme: colorScheme))
				print("loaded \(coordinate.cacheURL(for: size, span: span, colorScheme: colorScheme))")
				status = .loaded(Image(uiImage: image))
				return
			} catch {
				print(error)
			}

			let image = try await generate(size: size)

			withAnimation {
				self.status = .loaded(image)
			}
		}
	}

	func generate(size: CGSize) async throws -> Image {
		async let light = try generateColorScheme(size: size, colorScheme: .light)
		async let dark = try generateColorScheme(size: size, colorScheme: .dark)

		_ = try await light
		_ = try await dark

		if colorScheme == .light {
			return try await light
		} else {
			return try await dark
		}
	}

	func generateColorScheme(size: CGSize, colorScheme: ColorScheme) async throws -> Image {
		guard CLLocationCoordinate2DIsValid(region.center) else {
			throw MapThumbnailError.invalidCoordinate
		}

		let options: MKMapSnapshotter.Options = .init()
		options.region = region

		options.size = size
		options.mapType = .standard
		options.showsBuildings = true
		options.traitCollection = options.traitCollection.modifyingTraits {
			$0.userInterfaceStyle = colorScheme == .light ? .light : .dark
		}

		let snapshotter = MKMapSnapshotter(
			options: options
		)

		let uiImage = try await snapshotter.start(with: .main).image
		let data = uiImage.pngData()

		if let data {
			do {
				let cacheURL = coordinate.cacheURL(for: size, span: span, colorScheme: colorScheme)
				try data.write(to: cacheURL)
				print("generated \(cacheURL)")
			} catch {
				status = .error(error.localizedDescription)
			}
		}

		return Image(uiImage: uiImage)
	}
}

private extension Coordinate {
	func cacheURL(for size: CGSize, span: MKCoordinateSpan, colorScheme: ColorScheme) -> URL {
		let coords = "\(latitude)-\(longitude)"
			.components(separatedBy: ".")
			.joined(separator: "-")

		let span = "\(span.latitudeDelta)-\(span.longitudeDelta)"
			.components(separatedBy: ".")
			.joined(separator: "-")

		let color = colorScheme == .light ? "light" : "dark"

		return URL.temporaryDirectory.appending(path: "\(coords)-\(span)-\(size.width)x\(size.height)-\(color).png")
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
				span: .within(meters: 1500)
			)
			.frame(width: 200, height: 200)

			Button("Clear Cache") {
				try! FileManager.default.removeItem(
					at: coordinate.cacheURL(
						for: .init(width: 200, height: 200),
						span: .within(meters: 1500),
						colorScheme: .light
					)
				)

				try! FileManager.default.removeItem(
					at: coordinate.cacheURL(
						for: .init(width: 200, height: 200),
						span: .within(meters: 1500),
						colorScheme: .dark
					)
				)
			}
		}
	}
#endif
