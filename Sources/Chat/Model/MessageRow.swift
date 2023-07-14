//
//  Created by Alisa Mylnikov
//

import Foundation

public enum PositionInGroup {
    case first
    case middle
    case last
    case single // the only message in its group
}

struct MessageRow: Equatable {
    let message: Message
    let positionInGroup: PositionInGroup
}

extension MessageRow: Identifiable {
    public typealias ID = String
    public var id: String {
        message.id
    }
}
