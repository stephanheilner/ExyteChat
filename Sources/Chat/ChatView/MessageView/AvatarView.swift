//
//  Created by Alisa Mylnikov
//

import SwiftUI

struct AvatarView: View {
    let user: User
    let avatarSize: CGFloat
    let textColor: Color
    let backgroundColor: Color
    let initials: String

    init(user: User, avatarSize: CGFloat, textColor: Color = .white, backgroundColor: Color = .gray) {
        self.user = user
        self.avatarSize = avatarSize
        self.textColor = textColor
        self.backgroundColor = backgroundColor

        initials = {
            let firstInitial = user.name.first.flatMap { String($0) } ?? ""
            if let range = user.name.range(of: " ", options: .backwards) {
                let lastWord = String(user.name[range.upperBound...])
                let lastInitial = lastWord.first.flatMap { String($0) } ?? ""
                return [firstInitial.uppercased(), lastInitial.uppercased()].joined()
            }
            return firstInitial
        }()
    }

    var body: some View {
        if let url = user.avatarURL {
            CachedAsyncImage(url: url, urlCache: .imageCache) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Rectangle().fill(Color.gray)
            }
            .viewSize(avatarSize)
            .clipShape(Circle())
        } else {
            Text(initials)
                .foregroundColor(textColor)
                .font(.footnote)
                .fontWeight(.medium)
                .viewSize(avatarSize)
                .background(backgroundColor)
                .clipShape(Circle())
        }
    }
}

struct AvatarView_Previews: PreviewProvider {
    static var previews: some View {
        AvatarView(
            user: User(id: "", name: "", avatarURL: URL(string: "https://placeimg.com/640/480/sepia"), isCurrentUser: true),
            avatarSize: 32
        )
    }
}
