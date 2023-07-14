//
//  Created by Alisa Mylnikov
//

import SwiftUI

struct AttachmentsGrid: View {
    let onTap: (any Attachment) -> Void
    let maxImages: Int = 4 // TODO: Make injectable

    private let single: (any Attachment)?
    private let grid: [any Attachment]
    private let onlyOne: Bool

    private let hidden: String?
    private let showMoreAttachmentId: String?

    init(attachments: [any Attachment], onTap: @escaping (any Attachment) -> Void) {
        var toShow = attachments

        if toShow.count > maxImages {
            toShow = attachments.prefix(maxImages).map { $0 }
            hidden = "+\(attachments.count - (maxImages - 1))"
            showMoreAttachmentId = attachments[safe: maxImages - 1]?.id
        } else {
            hidden = nil
            showMoreAttachmentId = nil
        }
        if toShow.count % 2 == 0 {
            single = nil
            grid = toShow
        } else {
            single = toShow.first
            grid = toShow.dropFirst().map { $0 }
        }
        onlyOne = attachments.count == 1
        self.onTap = onTap
    }

    var columns: [GridItem] {
        [GridItem(.flexible()), GridItem(.flexible())]
    }

    var body: some View {
        VStack(spacing: 4) {
            if let attachment = single {
                AttachmentCell(attachment: attachment, onTap: onTap)
                    .frame(width: 204, height: grid.isEmpty ? 200 : 100)
                    .clipped()
                    .cornerRadius(onlyOne ? 0 : 12)
            }
            if !grid.isEmpty {
                ForEach(pair(), id: \.id) { pair in
                    HStack(spacing: 4) {
                        AttachmentCell(attachment: pair.left, onTap: onTap)
                            .frame(width: 100, height: 100)
                            .clipped()
                            .cornerRadius(12)
                        AttachmentCell(attachment: pair.right, onTap: onTap)
                            .frame(width: 100, height: 100)
                            .clipped()
                            .overlay {
                                if pair.right.id == showMoreAttachmentId, let hidden {
                                    ZStack {
                                        RadialGradient(
                                            colors: [
                                                .black.opacity(0.8),
                                                .black.opacity(0.6),
                                            ],
                                            center: .center,
                                            startRadius: 0,
                                            endRadius: 90
                                        )
                                        Text(hidden)
                                            .font(.body)
                                            .bold()
                                            .foregroundColor(.white)
                                    }
                                    .allowsHitTesting(false)
                                }
                            }
                            .cornerRadius(12)
                    }
                }
            }
        }
    }
}

private extension AttachmentsGrid {
    func pair() -> [AttachmentsPair] {
        stride(from: 0, to: grid.count - 1, by: 2)
            .map { AttachmentsPair(left: grid[$0], right: grid[$0 + 1]) }
    }
}

struct AttachmentsPair {
    let left: any Attachment
    let right: any Attachment

    var id: String {
        left.id + "+" + right.id
    }
}

#if DEBUG
    struct AttachmentsGrid_Preview: PreviewProvider {
        private static let examples = [1, 2, 3, 4, 5, 10]

        static var previews: some View {
            Group {
                ForEach(examples, id: \.self) { count in
                    ScrollView {
                        AttachmentsGrid(attachments: .random(count: count), onTap: { _ in })
                            .padding()
                            .background(Color.white)
                    }
                }
                .padding()
                .background(Color.secondary)
            }
        }
    }

    extension [any Attachment] {
        static func random(count: Int) -> [any Attachment] {
            Swift.Array(repeating: 0, count: count)
                .map { _ in randomAttachment() }
        }

        private static func randomAttachment() -> any Attachment {
            if Int.random(in: 0 ... 3) == 0 {
                return VideoAttachment.random()
            } else {
                return ImageAttachment.random()
            }
        }
    }

    extension ImageAttachment {
        static func random() -> ImageAttachment {
            ImageAttachment(id: UUID().uuidString, url: URL(string: "https://placeimg.com/640/480/sepia")!)
        }
    }

    extension VideoAttachment {
        static func random() -> ImageAttachment {
            ImageAttachment(id: UUID().uuidString, url: URL(string: "https://placeimg.com/640/480/sepia")!)
        }
    }
#endif
