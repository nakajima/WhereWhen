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

		var body: some View {
			NavigationStack {
				content()
					.environment(\.database, .memory)
					.environmentObject(FourskieCoordinator(database: .memory))
					.environment(LocationListener(database: .memory))
			}
		}
	}
#endif
