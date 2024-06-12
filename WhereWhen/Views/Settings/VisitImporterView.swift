//
//  VisitImporterView.swift
//  WhereWhen
//
//  Created by Pat Nakajima on 6/11/24.
//

import Database
import Foundation
import LibWhereWhen
import PlaceResolver
import SwiftUI

struct VisitImporterSelectionView: View {
	@Environment(\.navigationPath) var navigation

	let importer: VisitImporter

	var body: some View {
		List {
			if importer.lines.isEmpty {
				ContentUnavailableView("No visits found to import.", systemImage: "mappin.slash")
			}

			ForEach(importer.lines) { line in
				VisitImporterLineCellView(line: line)
			}
		}
		.toolbar {
			Button("Done") {
				navigation.popToRoot()
			}
		}
	}
}

struct VisitImporterView: View {
	@State private var input: String = ""
	@Environment(\.navigationPath) var navigation

	var body: some View {
		List {
			Section(
				header: Text("Enter visit.log text:"),
				footer: Text("You can get this text if you export your data. You probably shouldn’t need to though.")
			) {
				TextEditor(text: $input)
					.frame(minHeight: 100)
			}

			Button(action: self.import) {
				Text("Import")
			}
		}
		.navigationTitle("Importer")
		.navigationBarTitleDisplayMode(.inline)
	}

	func `import`() {
		let importer = VisitImporter(from: input)
		navigation.append(.settingsVisitImporterSelection(importer))
	}
}

#if DEBUG
	#Preview {
		PreviewsWrapper {
			VisitImporterView()
		}
	}

	#Preview {
		PreviewsWrapper {
			VisitImporterSelectionView(
				importer: VisitImporter(
					from: """
					+37.36267712|-122.02508251|2024-06-11T19:06:04Z
					+37.36291665|-122.02496126|2024-06-11T19:56:04Z
					+37.38842479|-122.03036462|2024-06-11T20:03:10Z
					+37.38842479|-122.03036462|2024-06-11T20:03:12Z
					+37.38827038|-122.03042774|2024-06-11T20:21:19Z
					+37.38844429|-122.03029019|2024-06-11T20:35:27Z
					+37.38844429|-122.03029019|2024-06-11T20:35:27Z
					+37.38720608|-122.03118657|2024-06-11T20:41:01Z
					+37.36227821|-122.02507570|2024-06-11T20:53:44Z
					+37.36227821|-122.02507570|2024-06-11T20:53:44Z
					"""
				)
			)
		}
	}
#endif
