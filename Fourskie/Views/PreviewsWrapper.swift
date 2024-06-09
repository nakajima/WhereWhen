//
//  PreviewsWrapper.swift
//  Fourskie
//
//  Created by Pat Nakajima on 6/5/24.
//

import Foundation
import SwiftUI

#if DEBUG
	struct PreviewsWrapper<Content: View>: View {
		var content: () -> Content

		@StateObject var coordinator = FourskieCoordinator(database: .memory)

		var body: some View {
			return NavigationContainer(path: $coordinator.navigation) {
				content()
					.environment(\.database, .memory)
					.environmentObject(coordinator)
					.environment(LocationListener(database: .memory))
			}
		}
	}
#endif
