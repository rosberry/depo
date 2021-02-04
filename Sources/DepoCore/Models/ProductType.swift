//
// Copyright © 2021 Rosberry. All rights reserved.
//

import Foundation

public enum ProductType: String {
    case framework = "com.apple.product-type.framework"
    case staticLibrary = "com.apple.product-type.library.static"
    case testBundle = "com.apple.product-type.bundle.unit-test"
    case unknown

    public init?(rawValue: String) {
        switch rawValue {
        case Self.framework.rawValue:
            self = .framework
        case Self.staticLibrary.rawValue:
            self = .staticLibrary
        case Self.testBundle.rawValue:
            self = .testBundle
        default:
            self = .unknown
        }
    }
}
