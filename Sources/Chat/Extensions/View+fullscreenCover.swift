//
//  Created by Alisa Mylnikov
//

import SwiftUI

extension View {
    func transparentNonAnimatingFullScreenCover(item: Binding<(some Equatable & Identifiable)?>, @ViewBuilder content: @escaping () -> some View) -> some View {
        modifier(TransparentNonAnimatableFullScreenModifier(item: item, fullScreenContent: content))
    }
}

private struct TransparentNonAnimatableFullScreenModifier<Item, FullScreenContent>: ViewModifier where Item: Equatable, Item: Identifiable, FullScreenContent: View {
    @Binding var item: Item?
    let fullScreenContent: () -> (FullScreenContent)

    func body(content: Content) -> some View {
        content
            .onChange(of: item) { _ in
                UIView.setAnimationsEnabled(false)
            }
            .fullScreenCover(item: $item) { _ in
                ZStack {
                    fullScreenContent()
                }
                .background(FullScreenCoverBackgroundRemovalView())
                .onAppear {
                    if !UIView.areAnimationsEnabled {
                        UIView.setAnimationsEnabled(true)
                    }
                }
                .onDisappear {
                    if !UIView.areAnimationsEnabled {
                        UIView.setAnimationsEnabled(true)
                    }
                }
            }
    }
}

private struct FullScreenCoverBackgroundRemovalView: UIViewRepresentable {
    private class BackgroundRemovalView: UIView {
        override func didMoveToWindow() {
            super.didMoveToWindow()
            superview?.superview?.backgroundColor = .clear
        }
    }

    func makeUIView(context _: Context) -> UIView {
        BackgroundRemovalView()
    }

    func updateUIView(_: UIView, context _: Context) {}
}
