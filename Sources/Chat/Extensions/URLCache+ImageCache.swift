//
//  Created by Alisa Mylnikov
//

import Foundation

extension URLCache {
    static let imageCache = URLCache(
        memoryCapacity: 512.megabytes(),
        diskCapacity: 2.gigabytes()
    )
}

private extension Int {
    func kilobytes() -> Int {
        self * 1024 * 1024
    }

    func megabytes() -> Int {
        kilobytes() * 1024
    }

    func gigabytes() -> Int {
        megabytes() * 1024
    }
}
