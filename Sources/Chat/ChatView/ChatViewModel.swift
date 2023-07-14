//
//  Created by Alisa Mylnikov
//

import Combine
import Foundation

public typealias ChatPaginationClosure = (Message) -> Void

final class ChatViewModel: ObservableObject {
    @Published private(set) var fullscreenAttachmentItem: (any Attachment)? = nil
    @Published var fullscreenAttachmentPresented = false

    @Published var messageMenuRow: MessageRow?

    public var didSendMessage: (DraftMessage) -> Void = { _ in }

    func presentAttachmentFullScreen(_ attachment: any Attachment) {
        fullscreenAttachmentItem = attachment
        fullscreenAttachmentPresented = true
    }

    func dismissAttachmentFullScreen() {
        fullscreenAttachmentPresented = false
        fullscreenAttachmentItem = nil
    }

    func sendMessage(_ message: DraftMessage) {
        didSendMessage(message)
    }
}
