//
//  SettingsView.swift
//  Fourskie
//
//  Created by Pat Nakajima on 6/4/24.
//

import Foundation
import SwiftUI

struct SettingsView: View {
	@Environment(LocationListener.self) var location

	var body: some View {
		List {
			NavigationLink("Logs", destination: DiskLoggerViewer(logger: location.logger))
		}
	}
}
