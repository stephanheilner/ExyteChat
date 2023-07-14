//
//  Created by Alisa Mylnikov
//

import SwiftUI

struct ChatMessageView<MessageContent: View>: View {
    typealias MessageBuilderClosure = ChatView<MessageContent, EmptyView>.MessageBuilderClosure

    @ObservedObject var viewModel: ChatViewModel

    var messageBuilder: MessageBuilderClosure?

    let row: MessageRow
    let avatarSize: CGFloat
    let messageUseMarkdown: Bool
    let isDisplayingMessageMenu: Bool

    var body: some View {
        Group {
            if let messageBuilder {
                messageBuilder(row.message, row.positionInGroup) { attachment in
                    viewModel.presentAttachmentFullScreen(attachment)
                }
            } else {
                MessageView(
                    viewModel: viewModel,
                    message: row.message,
                    positionInGroup: row.positionInGroup,
                    avatarSize: avatarSize,
                    messageUseMarkdown: messageUseMarkdown,
                    isDisplayingMessageMenu: isDisplayingMessageMenu
                )
            }
        }
        .id(row.message.id)
    }
}
