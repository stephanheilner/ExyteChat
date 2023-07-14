//
//  Created by Alisa Mylnikov
//

import AVKit
import Foundation

extension AVPlayer {
    var isPlaying: Bool {
        rate != 0 && error == nil
    }
}
