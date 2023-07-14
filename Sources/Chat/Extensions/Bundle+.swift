//
//  Created by Alisa Mylnikov
//

import Foundation

private final class BundleToken {
    static let bundle: Bundle = {
        #if SWIFT_PACKAGE
            return Bundle.module
        #else
            return Bundle(for: BundleToken.self)
        #endif
    }()

    private init() {}
}

extension Bundle {
    static var current: Bundle {
        BundleToken.bundle
    }
}
