//
//  Created by Alisa Mylnikov
//

import FloatingButton
import enum FloatingButton.Alignment
import SwiftUI

enum MessageMenuAction {
    case reply
    case delete
    case view
}

struct MessageMenu<MainButton: View>: View {
    @Environment(\.chatTheme) private var theme

    @Binding var isShowingMenu: Bool
    @Binding var menuButtonsSize: CGSize

    var alignment: Alignment
    var leadingPadding: CGFloat
    var trailingPadding: CGFloat
    var mainButton: () -> MainButton
    var onAction: (MessageMenuAction) -> Void

    var isReplyEnabled: Bool
    var isDeleteEnabled: Bool
    var isViewEnabled: Bool

    var menuButtons: [some View] {
        [
            isReplyEnabled ? menuButton(title: "Reply", icon: theme.images.messageMenu.reply, action: .reply) : nil,
            isDeleteEnabled ? menuButton(title: "Delete", icon: theme.images.messageMenu.delete, action: .delete) : nil,
            isViewEnabled ? menuButton(title: "View", icon: theme.images.messageMenu.forward, action: .view) : nil,
        ].compactMap { $0 }
    }

    var body: some View {
        FloatingButton(mainButtonView: mainButton().allowsHitTesting(false), buttons: menuButtons, isOpen: $isShowingMenu)
            .straight()
            .initialOpacity(0)
            .direction(.bottom)
            .alignment(alignment)
            .spacing(2)
            .animation(.linear(duration: 0.2))
            .menuButtonsSize($menuButtonsSize)
    }

    func menuButton(title: String, icon: Image, action: MessageMenuAction) -> some View {
        HStack(spacing: 0) {
            if alignment == .left {
                Color.clear.viewSize(leadingPadding)
            }

            ZStack {
                theme.colors.buttonBackground
                    .background(.ultraThinMaterial)
                    .opacity(0.7)
                    .cornerRadius(16)

                Label(title: { Text(title) }, icon: { icon })
                    .foregroundColor(theme.colors.textDarkContext)
                    .padding(.vertical, 11)
                    .padding(.horizontal, 12)
            }
            .frame(minWidth: 150)
            .fixedSize()
            .onTapGesture {
                onAction(action)
            }

            if alignment == .right {
                Color.clear.viewSize(trailingPadding)
            }
        }
    }
}
