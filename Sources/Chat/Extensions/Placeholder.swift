//
//  Created by Alisa Mylnikov
//

import SwiftUI

extension View {
    func placeholder(when shouldShow: Bool,
                     alignment: Alignment = .leading,
                     @ViewBuilder placeholder: () -> some View) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}
