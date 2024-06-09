//
//  SettingsView.swift
//  Fourskie
//
//  Created by Pat Nakajima on 6/4/24.
//

import Foundation
import SwiftUI

struct SettingsView: View {
	@Environment(\.database) var database
	@Environment(LocationListener.self) var location

	var body: some View {
		List {
			ShareLink(item: database.url) { Text("Export Database") }
			NavigationLink("Logs", destination: DiskLoggerViewer(logger: location.logger))

			Section {
				NavigationLink("Ignored Places", destination: IgnoredPlacesListView())
			}
		}
	}
}
