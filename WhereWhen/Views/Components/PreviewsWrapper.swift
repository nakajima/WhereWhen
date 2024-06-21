//
//  PreviewsWrapper.swift
//  WhereWhen
//
//  Created by Pat Nakajima on 6/5/24.
//

import Database
import Foundation
import SwiftUI

#if DEBUG
	struct PreviewsWrapper<Content: View>: View {
		var content: () -> Content

		@State var coordinator = WhereWhenCoordinator(database: .memory)
		@State private var path: [Route] = []

		var body: some View {
			return NavigationContainer(path: $path) {
				content()
					.environment(\.database, .memory)
					.environment(\.coordinator, coordinator)
					.environment(LocationListener(database: .memory))
			}
		}
	}
#endif
