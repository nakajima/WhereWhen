//
//  ExportDataView.swift
//  WhereWhen
//
//  Created by Pat Nakajima on 6/25/24.
//

import Database
import GRDBQuery
import LibWhereWhen
import SwiftUI

struct JSONTextView<Value: Encodable>: View {
	var value: Value

	@State private var text = ""
	@State private var isPrettyPrinted = true

	var body: some View {
		TextEditor(text: .constant(text))
			.onAppear {
				generate()
			}
			.onChange(of: isPrettyPrinted) {
				generate()
			}
			.toolbar {
				ToolbarItem(placement: .topBarTrailing) {
					Button("Copy to Clipboard") {
						UIPasteboard.general.string = text
					}
				}
				ToolbarItem(placement: .bottomBar) {
					Toggle("Pretty Print", isOn: $isPrettyPrinted.animation())
						.toggleStyle(.switch)
				}
			}
	}

	private func generate() {
		let encoder = JSONEncoder()
		encoder.outputFormatting = isPrettyPrinted ? .prettyPrinted : []
		encoder.dateEncodingStrategy = .iso8601
		withAnimation {
			self.text = try! String(data: encoder.encode(value), encoding: .utf8)!
		}
	}
}

struct ExportDataView: View {
	@State private var exportURL: URL?
	@Query(ListQueryRequest<Place>()) var places: [Place]
	@Query(CheckinListRequest()) var checkins: [Checkin]

	var body: some View {
		List {
			if let exportURL {
				ShareLink(item: exportURL) {
					Text("Share Archive")
				}
			} else {
				HStack {
					Text("Generating archive…")
						.foregroundStyle(.secondary)
						.onAppear {
							exportDatabase()
						}
					Spacer()
					ProgressView()
				}
			}

			NavigationLink("Places JSON") {
				JSONTextView(value: places)
			}
			NavigationLink("Checkins JSON") {
				JSONTextView(value: checkins)
			}
		}
	}

	func exportDatabase() {
		var error: NSError?
		let coordinator = NSFileCoordinator()
		coordinator.coordinate(readingItemAt: URL.documentsDirectory, options: [.forUploading], error: &error) { zipUrl in
			let tmpUrl = try! FileManager.default.url(
				for: .itemReplacementDirectory,
				in: .userDomainMask,
				appropriateFor: zipUrl,
				create: true
			).appendingPathComponent("WhereWhen.zip")

			try! FileManager.default.moveItem(at: zipUrl, to: tmpUrl)
			self.exportURL = tmpUrl
		}
	}
}

#if DEBUG
	#Preview {
		PreviewsWrapper {
			ExportDataView()
		}
	}
#endif
