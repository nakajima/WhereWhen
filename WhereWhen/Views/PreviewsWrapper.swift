//
//  PreviewsWrapper.swift
//  WhereWhen
//
//  Created by Pat Nakajima on 6/5/24.
//

import Foundation
import SwiftUI
import Database

#if DEBUG
	struct PreviewsWrapper<Content: View>: View {
		var content: () -> Content

		@StateObject var coordinator = WhereWhenCoordinator(database: .memory)
		@State private var path: [Route] = []

		var body: some View {
			return NavigationContainer(path: $path) {
				content()
					.environment(\.database, .memory)
					.environmentObject(coordinator)
					.environment(LocationListener(database: .memory))
			}
		}
	}
#endif
