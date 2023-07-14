//
//  Created by Alisa Mylnikov
//

import Foundation
import SwiftUI

struct FrameGetter: ViewModifier {
    @Binding var frame: CGRect

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { proxy -> AnyView in
                    DispatchQueue.main.async {
                        let rect = proxy.frame(in: .global)
                        // This avoids an infinite layout loop
                        if rect.integral != frame.integral {
                            frame = rect
                        }
                    }
                    return AnyView(EmptyView())
                }
            )
    }
}

struct SizeGetter: ViewModifier {
    @Binding var size: CGSize

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { proxy -> Color in
                    if proxy.size != size {
                        DispatchQueue.main.async {
                            size = proxy.size
                        }
                    }
                    return Color.clear
                }
            )
    }
}

public extension View {
    func frameGetter(_ frame: Binding<CGRect>) -> some View {
        modifier(FrameGetter(frame: frame))
    }

    func sizeGetter(_ size: Binding<CGSize>) -> some View {
        modifier(SizeGetter(size: size))
    }
}

struct MessageMenuPreferenceKey: PreferenceKey {
    typealias Value = [String: CGRect]

    static var defaultValue: Value = [:]

    static func reduce(value: inout Value, nextValue: () -> Value) {
        value.merge(nextValue()) { _, new in new }
    }
}

struct MessageMenuPreferenceViewSetter: View {
    let id: String

    var body: some View {
        GeometryReader { geometry in
            Rectangle()
                .fill(Color.clear)
                .preference(key: MessageMenuPreferenceKey.self,
                            value: [id: geometry.frame(in: .global)])
        }
    }
}
