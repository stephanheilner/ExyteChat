//
//  Created by Alisa Mylnikov
//

import Foundation
import SwiftUI

struct CustomFocus<T: Hashable>: ViewModifier {
    @Binding var binding: T
    @FocusState var focus: Bool
    var equals: T

    init(_ binding: Binding<T>, equals: T) {
        _binding = binding
        self.equals = equals
        focus = (binding.wrappedValue == equals)
    }

    func body(content: Content) -> some View {
        content
            .focused($focus, equals: true)
            .onChange(of: binding) {
                focus = ($0 == equals)
            }
            .onChange(of: focus) {
                if $0 {
                    binding = equals
                }
            }
    }
}

extension View {
    func customFocus<Value>(_ binding: Binding<Value>, equals value: Value) -> some View where Value: Hashable {
        modifier(CustomFocus(binding, equals: value))
    }
}
