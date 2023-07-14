//
//  Created by Alisa Mylnikov
//

import Combine
import Foundation

final class MockChatInteractor: ChatInteractorProtocol {
    private lazy var chatData = MockChatData()

    private lazy var chatState = CurrentValueSubject<[MockMessage], Never>(generateStartMessages())
    private lazy var sharedState = chatState.share()

    private let isActive: Bool
    private var isLoading = false
    private var lastDate = Date()

    private var subscriptions = Set<AnyCancellable>()

    var messages: AnyPublisher<[MockMessage], Never> {
        sharedState.eraseToAnyPublisher()
    }

    var senders: [MockUser] {
        var members = [chatData.steve, chatData.tim]
        if isActive { members.append(chatData.bob) }
        return members
    }

    var otherSenders: [MockUser] {
        senders.filter { !$0.isCurrentUser }
    }

    init(isActive: Bool = false) {
        self.isActive = isActive
    }

    /// TODO: Generate error with random chance
    /// TODO: Save images from url to files. Imitate upload process
    func send(message: MockCreateMessage) {
        if message.uid != nil {
            guard let index = chatState.value.firstIndex(where: { $0.uid == message.uid }) else {
                // TODO: Create error
                return
            }
            chatState.value.remove(at: index)
        }
        let message = message.toMockMessage(id: message.uid ?? UUID().uuidString, user: chatData.tim, status: .sending)
        chatState.value.append(message)
    }

    func connect() {
        Timer.publish(every: 2, on: .main, in: .default)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateSendingStatuses()
                if self?.isActive ?? false {
                    self?.generateNewMessage()
                }
            }
            .store(in: &subscriptions)
    }

    func disconnect() {
        subscriptions.removeAll()
    }

    func loadNextPage() -> Future<Bool, Never> {
        Future<Bool, Never> { [weak self] promise in
            guard let self, !self.isLoading else {
                promise(.success(false))
                return
            }
            isLoading = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                guard let self else { return }
                let messages = generateStartMessages()
                chatState.value = messages + chatState.value
                isLoading = false
                promise(.success(true))
            }
        }
    }
}

private extension MockChatInteractor {
    func generateStartMessages() -> [MockMessage] {
        defer {
            lastDate = lastDate.addingTimeInterval(-(60 * 60 * 24))
        }
        return (0 ... 10)
            .map { _ in
                chatData.randomMessage(senders: senders, date: lastDate.randomTime())
            }
            .sorted { lhs, rhs in
                lhs.createdAt < rhs.createdAt
            }
    }

    func generateNewMessage() {
        let message = chatData.randomMessage(senders: otherSenders)
        chatState.value.append(message)
    }

    func updateSendingStatuses() {
        let updated = chatState.value.map {
            var message = $0
            if message.status == .sending {
                if Int.random(min: 0, max: 20) == 0 {
                    message.status = .error
                } else {
                    message.status = .sent
                }
            } else if message.status == .sent {
                message.status = .read
            }
            return message
        }
        chatState.value = updated
    }
}
