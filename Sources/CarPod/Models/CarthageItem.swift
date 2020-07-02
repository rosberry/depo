//
// Copyright (c) 2020 ___FULLUSERNAME___. All rights reserved.
//

import Foundation

struct CarthageItem: Codable {
    enum Kind: String, Codable {
        case binary
        case github
        case git
    }

    let kind: Kind
    let identifier: String
    let version: Version?
}
