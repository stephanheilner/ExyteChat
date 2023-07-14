//
//  Created by Alisa Mylnikov
//

import SwiftUI

extension View {
    func viewSize(_ size: CGFloat) -> some View {
        frame(width: size, height: size)
    }

    func circleBackground(_ color: Color) -> some View {
        background {
            Circle().fill(color)
        }
    }
}
