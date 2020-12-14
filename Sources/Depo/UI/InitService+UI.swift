//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import DepoCore

extension InitService.State: CustomStringConvertible {
    public var description: String {
        switch self {
        case .generatingEmptyDepofile:
            return "[1/1] generating empty Depofile"
        case let .generatingDepofile(paths):
            let files = [paths.cartfilePath, paths.podfilePath, paths.packageSwiftFilePath].compactMap { path in
                path
            }
            return "[1/1] generating Depofile from \(files.spaceJoined)"
        case let .shell(state):
            return state.description
        }
    }
}
