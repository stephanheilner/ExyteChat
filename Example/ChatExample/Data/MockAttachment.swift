//
//  Created by Alisa Mylnikov
//

import Chat
import Foundation

struct MockImage {
    let id: String
    let thumbnail: URL
    let full: URL

    func toChatAttachment() -> any Attachment {
        ImageAttachment(
            id: id,
            thumbnail: thumbnail,
            full: full
        )
    }
}

struct MockVideo {
    let id: String
    let thumbnail: URL
    let full: URL

    func toChatAttachment() -> any Attachment {
        VideoAttachment(
            id: id,
            thumbnail: thumbnail,
            full: full
        )
    }
}
