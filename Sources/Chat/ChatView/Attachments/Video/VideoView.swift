//
//  Created by Alisa Mylnikov
//

import AVKit
import SwiftUI

struct VideoView: View {
    @EnvironmentObject var mediaPagesViewModel: FullscreenMediaPagesViewModel
    @Environment(\.chatTheme) private var theme

    @StateObject var viewModel: VideoViewModel

    var body: some View {
        Group {
            if let player = viewModel.player {
                content(for: player)
            } else {
                ProgressView()
            }
        }
        .contentShape(Rectangle())
        .onAppear {
            viewModel.onStart()

            mediaPagesViewModel.toggleVideoPlaying = {
                viewModel.togglePlay()
            }
            mediaPagesViewModel.toggleVideoMuted = {
                viewModel.toggleMute()
            }
        }
        .onDisappear {
            viewModel.onStop()
        }
        .onChange(of: viewModel.isPlaying) { newValue in
            mediaPagesViewModel.videoPlaying = newValue
        }
        .onChange(of: viewModel.isMuted) { newValue in
            mediaPagesViewModel.videoMuted = newValue
        }
    }

    func content(for player: AVPlayer) -> some View {
        VideoPlayer(player: player)
    }
}
