//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

struct SwiftPackage {
    let url: URL
    let exactVersion: String

    var name: String {
        String(url.lastPathComponent.dropLast(".git".count))
    }
}

extension SwiftPackage: Codable {

}
