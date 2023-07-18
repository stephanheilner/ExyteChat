//
//  Created by Alisa Mylnikov
//

import FloatingButton
import Introspect
import SwiftUI

public struct ChatView<MessageContent: View, InputViewContent: View>: View {
    /// To build a custom message view use the following parameters passed by this closure:
    /// - message containing user, attachments, etc.
    /// - position of message in its continuous group of messages from the same user
    /// - pass attachment to this closure to use ChatView's fullscreen media viewer
    public typealias MessageBuilderClosure = (Message, PositionInGroup, @escaping (any Attachment) -> Void) -> MessageContent

    public typealias InputViewBuilderClosure = (Binding<String>, InputViewAttachments, InputViewState, InputViewStyle, @escaping (InputViewAction) -> Void) -> InputViewContent

    public typealias DeleteActionClosure = (Message) -> Void
    public typealias ViewMessageActionClosure = (Message) -> Void

    @Environment(\.safeAreaInsets) private var safeAreaInsets
    @Environment(\.chatTheme) private var theme
    @Environment(\.mediaPickerTheme) private var pickerTheme

    let didSendMessage: (DraftMessage) -> Void

    /// provide custom message view builder
    var messageBuilder: MessageBuilderClosure? = nil

    /// provide custom input view builder
    var inputViewBuilder: InputViewBuilderClosure? = nil

    var deleteAction: DeleteActionClosure? = nil
    var viewMessageAction: ViewMessageActionClosure? = nil

    var avatarSize: CGFloat = 32
    var assetsPickerLimit: Int = 10
    var messageUseMarkdown: Bool = false
    var chatTitle: String?

    private let sections: [MessagesSection]
    @Binding private var messages: [Message]

    @StateObject private var viewModel = ChatViewModel()
    @StateObject private var inputViewModel = InputViewModel()
    @StateObject private var globalFocusState = GlobalFocusState()
    @StateObject private var paginationState = PaginationState()

    @State private var inputFieldId = UUID()

    @State private var isScrolledToBottom: Bool = true
    @State private var shouldScrollToTop: () -> Void = {}

    @State private var isShowingMenu = false
    @State private var needsScrollView = false
    @State private var readyToShowScrollView = false
    @State private var menuButtonsSize: CGSize = .zero
    @State private var cellFrames = [String: CGRect]()
    @State private var menuCellPosition: CGPoint = .zero
    @State private var menuBgOpacity: CGFloat = 0
    @State private var menuCellOpacity: CGFloat = 0
    @State private var menuScrollView: UIScrollView?

    public init(messages: Binding<[Message]>,
                didSendMessage: @escaping (DraftMessage) -> Void,
                messageBuilder: @escaping MessageBuilderClosure,
                inputViewBuilder _: @escaping InputViewBuilderClosure,
                deleteAction: @escaping DeleteActionClosure,
                viewMessageAction: @escaping ViewMessageActionClosure) {
        _messages = messages
        self.didSendMessage = didSendMessage
        sections = ChatView.mapMessages(messages.wrappedValue)
        self.messageBuilder = messageBuilder
        self.deleteAction = deleteAction
        self.viewMessageAction = viewMessageAction
    }

    public var body: some View {
        VStack {
            ZStack(alignment: .bottomTrailing) {
                list

                if !isScrolledToBottom {
                    Button {
                        NotificationCenter.default.post(name: .onScrollToBottom, object: nil)
                    } label: {
                        theme.images.scrollToBottom
                            .frame(width: 40, height: 40)
                            .circleBackground(theme.colors.friendMessage)
                    }
                    .padding(8)
                }
            }

            Group {
                if let inputViewBuilder {
                    inputViewBuilder($inputViewModel.attachments.text, inputViewModel.attachments, inputViewModel.state, .message, inputViewModel.inputViewAction())
                } else {
                    InputView(
                        viewModel: inputViewModel,
                        inputFieldId: inputFieldId,
                        style: .message,
                        messageUseMarkdown: messageUseMarkdown
                    )
                }
            }
            .environmentObject(globalFocusState)
            .onAppear(perform: inputViewModel.onStart)
            .onDisappear(perform: inputViewModel.onStop)
        }
        .background(theme.colors.mainBackground)
        .fullScreenCover(isPresented: $viewModel.fullscreenAttachmentPresented) {
            let attachments = sections.flatMap { section in section.rows.flatMap(\.message.attachments) }
            let index = attachments.firstIndex { $0.id == viewModel.fullscreenAttachmentItem?.id }

            GeometryReader { g in
                FullscreenMediaPages(
                    viewModel: FullscreenMediaPagesViewModel(
                        attachments: attachments,
                        index: index ?? 0
                    ),
                    safeAreaInsets: g.safeAreaInsets,
                    onClose: { [weak viewModel] in
                        viewModel?.dismissAttachmentFullScreen()
                    }
                )
                .ignoresSafeArea()
            }
        }
        .fullScreenCover(isPresented: $inputViewModel.showPicker) {
            AttachmentsEditor(inputViewModel: inputViewModel, inputViewBuilder: inputViewBuilder, assetsPickerLimit: assetsPickerLimit, chatTitle: chatTitle, messageUseMarkdown: messageUseMarkdown)
                .environmentObject(globalFocusState)
        }
        .onChange(of: inputViewModel.showPicker) {
            if $0 {
                globalFocusState.focus = nil
            }
        }
    }

    @ViewBuilder
    var list: some View {
        UIList(viewModel: viewModel,
               paginationState: paginationState,
               isScrolledToBottom: $isScrolledToBottom,
               shouldScrollToTop: $shouldScrollToTop,
               messageBuilder: messageBuilder,
               avatarSize: avatarSize,
               messageUseMarkdown: messageUseMarkdown,
               sections: sections,
               messages: $messages)
            .onStatusBarTap {
                shouldScrollToTop()
            }
            .transparentNonAnimatingFullScreenCover(item: $viewModel.messageMenuRow) {
                if let row = viewModel.messageMenuRow {
                    ZStack(alignment: .topLeading) {
                        Color.primary
                            .opacity(menuBgOpacity)
                            .ignoresSafeArea(.all)

                        if needsScrollView {
                            ScrollView {
                                messageMenu(row)
                            }
                            .introspectScrollView { scrollView in
                                DispatchQueue.main.async {
                                    menuScrollView = scrollView
                                }
                            }
                            .opacity(readyToShowScrollView ? 1 : 0)
                        }
                        if !needsScrollView || !readyToShowScrollView {
                            messageMenu(row)
                                .position(menuCellPosition)
                        }
                    }
                    .onAppear {
                        DispatchQueue.main.async {
                            if let frame = cellFrames[row.id] {
                                showMessageMenu(frame)
                            }
                        }
                    }
                    .onTapGesture {
                        hideMessageMenu()
                    }
                }
            }
            .onPreferenceChange(MessageMenuPreferenceKey.self) {
                cellFrames = $0
            }
            .onTapGesture {
                globalFocusState.focus = nil
            }
            .onAppear {
                viewModel.didSendMessage = didSendMessage
                inputViewModel.didSendMessage = { value in
                    didSendMessage(value)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        NotificationCenter.default.post(name: .onScrollToBottom, object: nil)
                    }
                }
            }
    }

    func messageMenu(_ row: MessageRow) -> some View {
        MessageMenu(
            isShowingMenu: $isShowingMenu,
            menuButtonsSize: $menuButtonsSize,
            alignment: row.message.user.isCurrentUser ? .right : .left,
            leadingPadding: avatarSize + MessageView.horizontalAvatarPadding * 2,
            trailingPadding: MessageView.statusViewSize + MessageView.horizontalStatusPadding,
            mainButton: {
                ChatMessageView(viewModel: viewModel, messageBuilder: messageBuilder, row: row, avatarSize: avatarSize, messageUseMarkdown: messageUseMarkdown, isDisplayingMessageMenu: true)
                    .onTapGesture {
                        hideMessageMenu()
                    }
            },
            onAction: { action in
                onMessageMenuAction(row: row, action: action)
            },
            isReplyEnabled: row.message.isReplyEnabled,
            isDeleteEnabled: row.message.isDeleteEnabled && deleteAction != nil,
            isViewEnabled: row.message.isViewEnabled && viewMessageAction != nil
        )
        .frame(height: menuButtonsSize.height + (cellFrames[row.id]?.height ?? 0), alignment: .top)
        .opacity(menuCellOpacity)
    }

    func showMessageMenu(_ cellFrame: CGRect) {
        DispatchQueue.main.async {
            let wholeMenuHeight = menuButtonsSize.height + cellFrame.height
            let needsScrollTemp = wholeMenuHeight > UIScreen.main.bounds.height - safeAreaInsets.top - safeAreaInsets.bottom

            menuCellPosition = CGPoint(x: cellFrame.midX, y: cellFrame.minY + wholeMenuHeight / 2 - safeAreaInsets.top)
            menuCellOpacity = 1

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                var finalCellPosition = menuCellPosition
                if needsScrollTemp ||
                    cellFrame.minY + wholeMenuHeight + safeAreaInsets.bottom > UIScreen.main.bounds.height {
                    finalCellPosition = CGPoint(x: cellFrame.midX, y: UIScreen.main.bounds.height - wholeMenuHeight / 2 - safeAreaInsets.top - safeAreaInsets.bottom)
                }

                withAnimation(.linear(duration: 0.1)) {
                    menuBgOpacity = 0.7
                    menuCellPosition = finalCellPosition
                    isShowingMenu = true
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                needsScrollView = needsScrollTemp
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                readyToShowScrollView = true
                if let menuScrollView {
                    menuScrollView.contentOffset = CGPoint(x: 0, y: menuScrollView.contentSize.height - menuScrollView.frame.height + safeAreaInsets.bottom)
                }
            }
        }
    }

    func hideMessageMenu() {
        menuScrollView = nil
        withAnimation(.linear(duration: 0.1)) {
            menuCellOpacity = 0
            menuBgOpacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            viewModel.messageMenuRow = nil
            isShowingMenu = false
            needsScrollView = false
            readyToShowScrollView = false
        }
    }

    func onMessageMenuAction(row: MessageRow, action: MessageMenuAction) {
        hideMessageMenu()

        switch action {
        case .reply:
            inputViewModel.attachments.replyMessage = row.message.toReplyMessage()
            globalFocusState.focus = .uuid(inputFieldId)
        case .delete:
            deleteAction?(row.message)
        case .view:
            viewMessageAction?(row.message)
        }
    }
}

private extension ChatView {
    static func mapMessages(_ messages: [Message]) -> [MessagesSection] {
        let dates = Set(messages.map { $0.createdAt.startOfDay() })
            .sorted()
            .reversed()
        var result: [MessagesSection] = []

        for date in dates {
            let section = MessagesSection(
                date: date,
                rows: wrapMessages(messages.filter { $0.createdAt.isSameDay(date) })
            )
            result.append(section)
        }

        return result
    }

    static func wrapMessages(_ messages: [Message]) -> [MessageRow] {
        messages
            .enumerated()
            .map {
                let nextMessageExists = messages[safe: $0.offset + 1] != nil
                let nextMessageIsSameUser = messages[safe: $0.offset + 1]?.user.id == $0.element.user.id
                let prevMessageIsSameUser = messages[safe: $0.offset - 1]?.user.id == $0.element.user.id

                let position: PositionInGroup
                if nextMessageExists, nextMessageIsSameUser, prevMessageIsSameUser {
                    position = .middle
                } else if !nextMessageExists || !nextMessageIsSameUser, !prevMessageIsSameUser {
                    position = .single
                } else if nextMessageExists, nextMessageIsSameUser {
                    position = .first
                } else {
                    position = .last
                }

                return MessageRow(message: $0.element, positionInGroup: position)
            }
            .reversed()
    }
}

public extension ChatView {
    func avatarSize(avatarSize: CGFloat) -> ChatView {
        var view = self
        view.avatarSize = avatarSize
        return view
    }

    func messageUseMarkdown(messageUseMarkdown: Bool) -> ChatView {
        var view = self
        view.messageUseMarkdown = messageUseMarkdown
        return view
    }

    func assetsPickerLimit(assetsPickerLimit: Int) -> ChatView {
        var view = self
        view.assetsPickerLimit = assetsPickerLimit
        return view
    }

    /// when user scrolls to `offset`-th meassage from the end, call the handler function, so user can load more messages
    func enableLoadMore(offset: Int = 0, handler: @escaping ChatPaginationClosure) -> ChatView {
        var view = self
        view._paginationState = StateObject(wrappedValue: PaginationState(onEvent: handler, offset: offset))
        return view
    }

    func chatNavigation(title: String, status: String? = nil, cover: URL? = nil) -> some View {
        var view = self
        view.chatTitle = title
        return view.modifier(ChatNavigationModifier(title: title, status: status, cover: cover))
    }
}

public extension ChatView where MessageContent == EmptyView {
    init(messages: Binding<[Message]>,
         didSendMessage: @escaping (DraftMessage) -> Void,
         inputViewBuilder: @escaping InputViewBuilderClosure,
         deleteAction: DeleteActionClosure? = nil,
         viewMessageAction: ViewMessageActionClosure? = nil) {
        _messages = messages
        self.didSendMessage = didSendMessage
        sections = ChatView.mapMessages(messages.wrappedValue)
        self.inputViewBuilder = inputViewBuilder
        self.deleteAction = deleteAction
        self.viewMessageAction = viewMessageAction
    }
}

public extension ChatView where InputViewContent == EmptyView {
    init(messages: Binding<[Message]>,
         didSendMessage: @escaping (DraftMessage) -> Void,
         messageBuilder: @escaping MessageBuilderClosure,
         deleteAction: DeleteActionClosure? = nil,
         viewMessageAction: ViewMessageActionClosure? = nil) {
        _messages = messages
        self.didSendMessage = didSendMessage
        sections = ChatView.mapMessages(messages.wrappedValue)
        self.messageBuilder = messageBuilder
        self.deleteAction = deleteAction
        self.viewMessageAction = viewMessageAction
    }
}

public extension ChatView where MessageContent == EmptyView, InputViewContent == EmptyView {
    init(messages: Binding<[Message]>,
         didSendMessage: @escaping (DraftMessage) -> Void,
         deleteAction: DeleteActionClosure? = nil,
         viewMessageAction: ViewMessageActionClosure? = nil) {
        _messages = messages
        self.didSendMessage = didSendMessage
        self.deleteAction = deleteAction
        self.viewMessageAction = viewMessageAction
        sections = ChatView.mapMessages(messages.wrappedValue)
    }
}
