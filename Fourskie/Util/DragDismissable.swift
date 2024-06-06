//
//  DragDismissable.swift
//  Wub4
//
//  Created by Pat Nakajima on 7/17/23.
//

import SwiftUI

public struct DragDismissableModifier: ViewModifier {
	@State private var offset: CGFloat = 0
	var enabled: Bool = false
	var threshold = 200
	var onDismiss: () -> Void

	public init(enabled: Bool = false, threshold: Int = 200, onDismiss: @escaping () -> Void) {
		self.enabled = enabled
		self.threshold = threshold
		self.onDismiss = onDismiss
	}

	public func body(content: Content) -> some View {
		content
			.offset(y: offset)
			.gesture(DragGesture().onChanged { e in
				guard enabled else { return }

				withAnimation(.spring) {
					self.offset = e.translation.height
				}
			}.onEnded { e in
				if abs(e.predictedEndTranslation.height) > CGFloat(threshold) {
					onDismiss()
				}

				withAnimation(.spring) {
					self.offset = 0
				}
			})
			.animation(.spring, value: offset)
	}
}

public extension View {
	func dragDismissable(_ enabled: Bool = true, threshold: Int = 200, onDismiss: @escaping () -> Void) -> some View {
		modifier(DragDismissableModifier(enabled: enabled, threshold: threshold, onDismiss: onDismiss))
	}
}

#if DEBUG
	struct DragDismissableModifier_Previews: PreviewProvider {
		struct Container: View {
			@State private var isVisible = true

			var body: some View {
				ZStack {
					Color.blue

					if isVisible {
						VStack {
							Text("Drag dismiss me")
						}
						.padding()
						.background(.pink)
						.cornerRadius(12)
						.transition(.move(edge: .bottom).combined(with: .opacity))
						.dragDismissable {
							withAnimation(.spring) {
								isVisible = false
							}
						}
					}
				}
			}
		}

		static var previews: some View {
			Container()
		}
	}
#endif
