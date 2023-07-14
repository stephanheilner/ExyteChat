//
//  Created by Alisa Mylnikov
//

import Foundation

public struct User {
    public let id: String
    public let name: String
    public let avatarURL: URL?
    public let isCurrentUser: Bool

    public init(id: String, name: String, avatarURL: URL?, isCurrentUser: Bool) {
        self.id = id
        self.name = name
        self.avatarURL = avatarURL
        self.isCurrentUser = isCurrentUser
    }
}
