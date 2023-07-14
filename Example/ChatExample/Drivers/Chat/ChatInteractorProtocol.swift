//
//  Created by Alisa Mylnikov
//

import Combine
import Foundation

protocol ChatInteractorProtocol {
    var messages: AnyPublisher<[MockMessage], Never> { get }
    var senders: [MockUser] { get }
    var otherSenders: [MockUser] { get }

    func send(message: MockCreateMessage)

    func connect()
    func disconnect()

    func loadNextPage() -> Future<Bool, Never>
}
