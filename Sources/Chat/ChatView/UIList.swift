//
//  Created by Alisa Mylnikov
//

import SwiftUI

public extension Notification.Name {
    static let onScrollToBottom = Notification.Name("onScrollToBottom")
}

struct UIList<MessageContent: View>: UIViewRepresentable {
    typealias MessageBuilderClosure = ChatView<MessageContent, EmptyView>.MessageBuilderClosure

    @Environment(\.chatTheme) private var theme

    @ObservedObject var viewModel: ChatViewModel
    @ObservedObject var paginationState: PaginationState

    @Binding var isScrolledToBottom: Bool
    @Binding var shouldScrollToTop: () -> Void

    var messageBuilder: MessageBuilderClosure?

    let avatarSize: CGFloat
    let messageUseMarkdown: Bool
    let sections: [MessagesSection]
    @Binding var messages: [Message]

    @State private var isScrolledToTop = false

    private let updatesQueue = DispatchQueue(label: "updatesQueue", qos: DispatchQoS.background)
    @State private var updateSemaphore = DispatchSemaphore(value: 1)
    @State private var tableSemaphore = DispatchSemaphore(value: 0)

    func makeUIView(context: Context) -> UITableView {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.dataSource = context.coordinator
        tableView.delegate = context.coordinator
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.transform = CGAffineTransform(rotationAngle: .pi)

        tableView.showsVerticalScrollIndicator = false
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = UITableView.automaticDimension
        tableView.backgroundColor = UIColor(theme.colors.mainBackground)
        tableView.scrollsToTop = false

        NotificationCenter.default.addObserver(forName: .onScrollToBottom, object: nil, queue: nil) { _ in
            DispatchQueue.main.immediate {
                if !context.coordinator.sections.isEmpty {
                    tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: true)
                }
            }
        }

        DispatchQueue.main.immediate {
            shouldScrollToTop = {
                tableView.contentOffset = CGPoint(x: 0, y: tableView.contentSize.height - tableView.frame.height)
            }
        }

        return tableView
    }

    func updateUIView(_ tableView: UITableView, context: Context) {
        updatesQueue.immediate {
            updateSemaphore.wait()

            let prevSections = context.coordinator.sections
            guard prevSections != sections // No Change
            else {
                updateSemaphore.signal()
                return
            }

            DispatchQueue.main.immediate {
                tableView.performBatchUpdates {
                    applyInserts(tableView: tableView, prevSections: prevSections)
                    context.coordinator.sections = sections
                } completion: { _ in
                    updateSemaphore.signal()
                }
            }
        }
    }

    func applyEdits(tableView: UITableView, prevSections: [MessagesSection]) -> [MessagesSection] {
        var result = [MessagesSection]()
        let prevDates = prevSections.map(\.date)
        for sectionIndex in 0 ..< prevDates.count {
            let prevDate = prevDates[sectionIndex]
            guard let section = sections.first(where: { $0.date == prevDate }),
                  let prevSection = prevSections.first(where: { $0.date == prevDate })
            else { continue }

            var resultRows = [MessageRow]()
            for rowIndex in 0 ..< prevSection.rows.count {
                let prevRow = prevSection.rows[rowIndex]
                guard let row = section.rows.first(where: { $0.message.id == prevRow.message.id })
                else { continue }
                resultRows.append(row)

                if row != prevRow {
                    DispatchQueue.main.immediate {
                        tableView.reloadRows(at: [IndexPath(row: rowIndex, section: sectionIndex)], with: .none)
                    }
                }
            }
            result.append(MessagesSection(date: prevDate, rows: resultRows))
        }
        return result
    }

    func applyInserts(tableView: UITableView, prevSections: [MessagesSection]) {
        // compare sections without comparing messages inside them, just dates
        let dates = sections.map(\.date)
        let coordinatorDates = prevSections.map(\.date)

        let dif = dates.difference(from: coordinatorDates)
        for change in dif {
            switch change {
            case let .remove(offset, _, _):
                tableView.deleteSections([offset], with: .top)
            case let .insert(offset, _, _):
                tableView.insertSections([offset], with: .top)
            }
        }

        // compare rows for each section
        for section in sections {
            guard let index = prevSections.firstIndex(where: { $0.date == section.date }) else { continue }
            let dif = section.rows.difference(from: prevSections[index].rows)

            // animate insertions and removals
            for change in dif {
                switch change {
                case let .remove(offset, _, _):
                    tableView.deleteRows(at: [IndexPath(row: offset, section: index)], with: .top)
                case let .insert(offset, _, _):
                    tableView.insertRows(at: [IndexPath(row: offset, section: index)], with: .top)
                }
            }
        }
    }

    func makeCoordinator() -> Coordinator<MessageContent> {
        Coordinator(
            viewModel: viewModel,
            paginationState: paginationState,
            isScrolledToBottom: $isScrolledToBottom,
            isScrolledToTop: $isScrolledToTop,
            messageBuilder: messageBuilder,
            avatarSize: avatarSize,
            messageUseMarkdown: messageUseMarkdown,
            sections: sections,
            messages: $messages,
            mainBackgroundColor: theme.colors.mainBackground
        )
    }

    class Coordinator<MessageContent: View>: NSObject, UITableViewDataSource, UITableViewDelegate {
        @ObservedObject var viewModel: ChatViewModel
        @ObservedObject var paginationState: PaginationState

        @Binding var isScrolledToBottom: Bool
        @Binding var isScrolledToTop: Bool

        var messageBuilder: MessageBuilderClosure?

        let avatarSize: CGFloat
        let messageUseMarkdown: Bool
        var sections: [MessagesSection]
        @Binding var messages: [Message]

        let mainBackgroundColor: Color

        init(viewModel: ChatViewModel, paginationState: PaginationState, isScrolledToBottom: Binding<Bool>, isScrolledToTop: Binding<Bool>, messageBuilder: MessageBuilderClosure?, avatarSize: CGFloat, messageUseMarkdown: Bool, sections: [MessagesSection], messages: Binding<[Message]>, mainBackgroundColor: Color) {
            self.viewModel = viewModel
            self.paginationState = paginationState
            _isScrolledToBottom = isScrolledToBottom
            _isScrolledToTop = isScrolledToTop
            self.messageBuilder = messageBuilder
            self.avatarSize = avatarSize
            self.messageUseMarkdown = messageUseMarkdown
            self.sections = sections
            _messages = messages
            self.mainBackgroundColor = mainBackgroundColor
        }

        func numberOfSections(in _: UITableView) -> Int {
            sections.count
        }

        func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
            sections[section].rows.count
        }

        func tableView(_: UITableView, viewForFooterInSection section: Int) -> UIView? {
            let header = UIHostingController(rootView:
                Text(sections[section].formattedDate)
                    .font(.system(size: 11))
                    .rotationEffect(Angle(degrees: 180))
                    .padding(10)
                    .padding(.bottom, 8)
                    .foregroundColor(.gray)
            ).view
            header?.backgroundColor = UIColor(mainBackgroundColor)
            return header
        }

        func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
            0.1
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let tableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            tableViewCell.selectionStyle = .none
            tableViewCell.backgroundColor = UIColor(mainBackgroundColor)

            let row = sections[indexPath.section].rows[indexPath.row]
            tableViewCell.contentConfiguration = UIHostingConfiguration {
                ChatMessageView(viewModel: viewModel, messageBuilder: messageBuilder, row: row, avatarSize: avatarSize, messageUseMarkdown: messageUseMarkdown, isDisplayingMessageMenu: false)
                    .background(MessageMenuPreferenceViewSetter(id: row.id))
                    .rotationEffect(Angle(degrees: 180))
                    .onTapGesture {}
                    .onLongPressGesture {
                        self.viewModel.messageMenuRow = row
                    }
            }
            .minSize(width: 0, height: 0)
            .margins(.all, 0)

            return tableViewCell
        }

        func tableView(_: UITableView, willDisplay _: UITableViewCell, forRowAt indexPath: IndexPath) {
            let row = sections[indexPath.section].rows[indexPath.row]
            paginationState.handle(row.message, ids: messages.map(\.id))
        }

        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            isScrolledToBottom = scrollView.contentOffset.y <= 0
            isScrolledToTop = scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.frame.height - 1
        }
    }
}

public extension DispatchQueue {
    /// If already on the main thread, executes the closure on the current thread, else, asynchronously
    func immediate(execute closure: @escaping () -> Void) {
//        if Thread.isMainThread {
//            closure()
//        } else {
        async(execute: closure)
//        }
    }

    func after(_ delay: TimeInterval, execute closure: @escaping () -> Void) {
        asyncAfter(deadline: .now() + delay, execute: closure)
    }
}

public class Throttle<T> {
    private let dispatchQueue = DispatchQueue(label: "UIList.Throttler")
    private var dispatchWorkItem = DispatchWorkItem(block: {})
    private var previousRun = Date.distantPast
    private let timeInterval: TimeInterval
    private let callback: (T) -> Void

    public init(_ timeInterval: TimeInterval, callback: @escaping (T) -> Void) {
        self.timeInterval = timeInterval
        self.callback = callback
    }

    public func call(_ t: T) {
        dispatchWorkItem.cancel()
        dispatchWorkItem = DispatchWorkItem { [weak self] in
            self?.previousRun = Date()
            self?.callback(t)
        }
        let delay: TimeInterval = Date().timeIntervalSince(previousRun) > timeInterval ? 0 : timeInterval
        dispatchQueue.asyncAfter(deadline: .now() + delay, execute: dispatchWorkItem)
    }
}

public extension Throttle where T == Void {
    func call() {
        call(())
    }
}
