//
//  Created by Alisa Mylnikov
//

import Combine
import Foundation

final class FullscreenMediaPagesViewModel: ObservableObject {
    var attachments: [any Attachment]
    @Published var index: Int

    @Published var showMinis = true
    @Published var offset: CGSize = .zero

    @Published var videoPlaying = false
    @Published var videoMuted = false

    @Published var toggleVideoPlaying = {}
    @Published var toggleVideoMuted = {}

    init(attachments: [any Attachment], index: Int) {
        self.attachments = attachments
        self.index = index
    }
}
