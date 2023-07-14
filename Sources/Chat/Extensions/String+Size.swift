//
//  Created by Alisa Mylnikov
//

import SwiftUI
import UIKit

extension String {
    func width(withConstrainedWidth width: CGFloat, font: UIFont, messageUseMarkdown: Bool) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = toAttrString(font: font, messageUseMarkdown: messageUseMarkdown).boundingRect(with: constraintRect,
                                                                                                        options: .usesLineFragmentOrigin,
                                                                                                        context: nil)

        return ceil(boundingBox.width)
    }

    func toAttrString(font: UIFont, messageUseMarkdown: Bool) -> NSAttributedString {
        var str = messageUseMarkdown ? (try? AttributedString(markdown: self)) ?? AttributedString(self) : AttributedString(self)
        str.setAttributes(AttributeContainer([.font: font]))
        return NSAttributedString(str)
    }

    public func lastLineWidth(labelWidth: CGFloat, font: UIFont, messageUseMarkdown: Bool) -> CGFloat {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let attrString = toAttrString(font: font, messageUseMarkdown: messageUseMarkdown)
        let labelSize = CGSize(width: labelWidth, height: .infinity)
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: labelSize)
        let textStorage = NSTextStorage(attributedString: attrString)

        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = .byWordWrapping
        textContainer.maximumNumberOfLines = 0

        let lastGlyphIndex = layoutManager.glyphIndexForCharacter(at: attrString.length - 1)
        let lastLineFragmentRect = layoutManager.lineFragmentUsedRect(
            forGlyphAt: lastGlyphIndex,
            effectiveRange: nil
        )

        return lastLineFragmentRect.maxX
    }
}
