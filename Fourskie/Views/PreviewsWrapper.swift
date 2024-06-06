//
//  PreviewsWrapper.swift
//  Fourskie
//
//  Created by Pat Nakajima on 6/5/24.
//

import Foundation
import SwiftData
import SwiftUI

#if DEBUG
	struct PreviewsWrapper<Content: View>: View {
		var content: () -> Content

		var body: some View {
			NavigationStack {
				content()
					.modelContainer(ModelContainer.preview)
					.environmentObject(FourskieCoordinator(container: ModelContainer.preview))
					.environment(LocationListener(container: ModelContainer.preview))
			}
		}
	}
#endif
