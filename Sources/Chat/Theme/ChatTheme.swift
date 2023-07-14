//
//  Created by Alisa Mylnikov
//

import SwiftUI

struct ChatThemeKey: EnvironmentKey {
    static var defaultValue: ChatTheme = ChatTheme()
}

extension EnvironmentValues {
    var chatTheme: ChatTheme {
        get { self[ChatThemeKey.self] }
        set { self[ChatThemeKey.self] = newValue }
    }
}

public extension View {
    func chatTheme(_ theme: ChatTheme) -> some View {
        environment(\.chatTheme, theme)
    }

    func chatTheme(colors: ChatTheme.Colors = .init(),
                   images: ChatTheme.Images = .init()) -> some View {
        environment(\.chatTheme, ChatTheme(colors: colors, images: images))
    }
}

public struct ChatTheme {
    public let colors: ChatTheme.Colors
    public let images: ChatTheme.Images

    public init(colors: ChatTheme.Colors = .init(),
                images: ChatTheme.Images = .init()) {
        self.colors = colors
        self.images = images
    }

    public struct Colors {
        public var grayStatus: Color
        public var errorStatus: Color

        public var inputLightContextBackground: Color
        public var inputDarkContextBackground: Color

        public var mainBackground: Color
        public var buttonBackground: Color
        public var addButtonBackground: Color
        public var sendButtonBackground: Color

        public var myMessage: Color
        public var friendMessage: Color

        public var textLightContext: Color
        public var textDarkContext: Color
        public var textMediaPicker: Color

        public var recordDot: Color

        public init(grayStatus: Color = Color(hex: "AFB3B8"),
                    errorStatus: Color = Color.red,
                    inputLightContextBackground: Color = Color(hex: "F2F3F5"),
                    inputDarkContextBackground: Color = Color(hex: "F2F3F5").opacity(0.12),
                    mainBackground: Color = .white,
                    buttonBackground: Color = Color(hex: "989EAC"),
                    addButtonBackground: Color = Color(hex: "#4F5055"),
                    sendButtonBackground: Color = Color(hex: "#4962FF"),
                    myMessage: Color = Color(hex: "4962FF"),
                    friendMessage: Color = Color(hex: "EBEDF0"),
                    textLightContext: Color = Color.black,
                    textDarkContext: Color = Color.white,
                    textMediaPicker: Color = Color(hex: "818C99"),
                    recordDot: Color = Color(hex: "F62121")) {
            self.grayStatus = grayStatus
            self.errorStatus = errorStatus
            self.inputLightContextBackground = inputLightContextBackground
            self.inputDarkContextBackground = inputDarkContextBackground
            self.mainBackground = mainBackground
            self.buttonBackground = buttonBackground
            self.addButtonBackground = addButtonBackground
            self.sendButtonBackground = sendButtonBackground
            self.myMessage = myMessage
            self.friendMessage = friendMessage
            self.textLightContext = textLightContext
            self.textDarkContext = textDarkContext
            self.textMediaPicker = textMediaPicker
            self.recordDot = recordDot
        }
    }

    public struct Images {
        public struct AttachMenu {
            public var camera: Image
            public var contact: Image
            public var document: Image
            public var location: Image
            public var photo: Image
            public var pickDocument: Image
            public var pickLocation: Image
            public var pickPhoto: Image
        }

        public struct InputView {
            public var add: Image
            public var arrowSend: Image
            public var attach: Image
            public var attachCamera: Image
            public var microphone: Image
        }

        public struct FullscreenMedia {
            public var play: Image
            public var pause: Image
            public var mute: Image
            public var unmute: Image
        }

        public struct MediaPicker {
            public var chevronDown: Image
            public var chevronRight: Image
            public var cross: Image
        }

        public struct Message {
            public var attachedDocument: Image
            public var checkmarks: Image
            public var error: Image
            public var muteVideo: Image
            public var pauseAudio: Image
            public var pauseVideo: Image
            public var playAudio: Image
            public var playVideo: Image
            public var sending: Image
        }

        public struct MessageMenu {
            public var delete: Image
            public var edit: Image
            public var forward: Image
            public var reply: Image
            public var retry: Image
            public var save: Image
            public var select: Image
        }

        public struct RecordAudio {
            public var cancelRecord: Image
            public var deleteRecord: Image
            public var lockRecord: Image
            public var pauseRecord: Image
            public var playRecord: Image
            public var sendRecord: Image
            public var stopRecord: Image
        }

        public struct Reply {
            public var cancelReply: Image
            public var replyToMessage: Image
        }

        public var backButton: Image
        public var scrollToBottom: Image

        public var attachMenu: AttachMenu
        public var inputView: InputView
        public var fullscreenMedia: FullscreenMedia
        public var mediaPicker: MediaPicker
        public var message: Message
        public var messageMenu: MessageMenu
        public var recordAudio: RecordAudio
        public var reply: Reply

        public init(camera: Image? = nil,
                    contact: Image? = nil,
                    document: Image? = nil,
                    location: Image? = nil,
                    photo: Image? = nil,
                    pickDocument: Image? = nil,
                    pickLocation: Image? = nil,
                    pickPhoto: Image? = nil,
                    add: Image? = nil,
                    arrowSend: Image? = nil,
                    attach: Image? = nil,
                    attachCamera: Image? = nil,
                    microphone: Image? = nil,
                    fullscreenPlay: Image? = nil,
                    fullscreenPause: Image? = nil,
                    fullscreenMute: Image? = nil,
                    fullscreenUnmute: Image? = nil,
                    chevronDown: Image? = nil,
                    chevronRight: Image? = nil,
                    cross: Image? = nil,
                    attachedDocument: Image? = nil,
                    checkmarks: Image? = nil,
                    error: Image? = nil,
                    muteVideo: Image? = nil,
                    pauseAudio: Image? = nil,
                    pauseVideo: Image? = nil,
                    playAudio: Image? = nil,
                    playVideo: Image? = nil,
                    sending: Image? = nil,
                    delete: Image? = nil,
                    edit: Image? = nil,
                    forward: Image? = nil,
                    reply: Image? = nil,
                    retry: Image? = nil,
                    save: Image? = nil,
                    select: Image? = nil,
                    cancelRecord: Image? = nil,
                    deleteRecord: Image? = nil,
                    lockRecord: Image? = nil,
                    pauseRecord: Image? = nil,
                    playRecord: Image? = nil,
                    sendRecord: Image? = nil,
                    stopRecord: Image? = nil,
                    cancelReply: Image? = nil,
                    replyToMessage: Image? = nil,
                    backButton: Image? = nil,
                    scrollToBottom: Image? = nil) {
            self.backButton = backButton ?? Image(systemName: "arrow.backward")
            self.scrollToBottom = scrollToBottom ?? Image(systemName: "chevron.down")

            attachMenu = AttachMenu(
                camera: camera ?? Image(systemName: "camera"),
                contact: contact ?? Image(systemName: "person.fill"),
                document: document ?? Image(systemName: "doc.plaintext.fill"),
                location: location ?? Image(systemName: "mappin"),
                photo: photo ?? Image(systemName: "photo"),
                pickDocument: pickDocument ?? Image(systemName: "doc.plaintext.fill"),
                pickLocation: pickLocation ?? Image(systemName: "mappin.circle.fill"),
                pickPhoto: pickPhoto ?? Image(systemName: "photo.fill")
            )

            inputView = InputView(
                add: add ?? Image(systemName: "plus"),
                arrowSend: arrowSend ?? Image(systemName: "arrow.up"),
                attach: attach ?? Image(systemName: "paperclip"),
                attachCamera: attachCamera ?? Image(systemName: "camera"),
                microphone: microphone ?? Image(systemName: "mic")
            )

            fullscreenMedia = FullscreenMedia(
                play: fullscreenPlay ?? Image(systemName: "play.fill"),
                pause: fullscreenPause ?? Image(systemName: "pause.fill"),
                mute: fullscreenMute ?? Image(systemName: "speaker.slash.fill"),
                unmute: fullscreenUnmute ?? Image(systemName: "speaker.fill")
            )

            mediaPicker = MediaPicker(
                chevronDown: chevronDown ?? Image(systemName: "chevron.down"),
                chevronRight: chevronRight ?? Image(systemName: "chevron.right"),
                cross: cross ?? Image(systemName: "xmark")
            )

            message = Message(
                attachedDocument: attachedDocument ?? Image(systemName: "doc.fill"),
                checkmarks: checkmarks ?? Image(systemName: "checkmark"),
                error: error ?? Image(systemName: "exclamationmark.octagon.fill"),
                muteVideo: muteVideo ?? Image(systemName: "speaker.slash"),
                pauseAudio: pauseAudio ?? Image(systemName: "pause.fill"),
                pauseVideo: pauseVideo ?? Image(systemName: "pause.circle.fill"),
                playAudio: playAudio ?? Image(systemName: "play.fill"),
                playVideo: playVideo ?? Image(systemName: "play.circle.fill"),
                sending: sending ?? Image(systemName: "clock")
            )

            messageMenu = MessageMenu(
                delete: delete ?? Image(systemName: "trash"),
                edit: edit ?? Image(systemName: "pencil"),
                forward: forward ?? Image(systemName: "arrow.turn.up.right"),
                reply: reply ?? Image(systemName: "arrow.turn.up.left"),
                retry: retry ?? Image(systemName: "arrow.triangle.2.circlepath"),
                save: save ?? Image(systemName: "square.and.arrow.down"),
                select: select ?? Image(systemName: "checkmark.circle")
            )

            recordAudio = RecordAudio(
                cancelRecord: cancelRecord ?? Image(systemName: "arrow.backward"),
                deleteRecord: deleteRecord ?? Image(systemName: "trash"),
                lockRecord: lockRecord ?? Image(systemName: "lock"),
                pauseRecord: pauseRecord ?? Image(systemName: "pause.fill"),
                playRecord: playRecord ?? Image(systemName: "play.fill"),
                sendRecord: sendRecord ?? Image(systemName: "square.and.arrow.up"),
                stopRecord: stopRecord ?? Image(systemName: "stop.fill")
            )

            self.reply = Reply(
                cancelReply: cancelReply ?? Image(systemName: "xmark.circle"),
                replyToMessage: replyToMessage ?? Image(systemName: "arrow.turn.up.left")
            )
        }
    }
}
