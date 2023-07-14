//
//  Created by Alisa Mylnikov
//

import SwiftUI

struct MessageTimeView: View {
    let text: String
    var textColor: Color = .white

    var body: some View {
        Text(text)
            .font(.caption)
            .foregroundColor(textColor)
            .opacity(0.4)
    }
}

struct MessageTimeWithCapsuleView: View {
    let text: String
    var textColor: Color = .white
    var backgroundColor: Color = .black.opacity(0.4)

    var body: some View {
        Text(text)
            .font(.caption)
            .foregroundColor(textColor)
            .opacity(0.8)
            .padding(.top, 4)
            .padding(.bottom, 4)
            .padding(.horizontal, 8)
            .background {
                Capsule()
                    .fill(backgroundColor)
            }
    }
}
