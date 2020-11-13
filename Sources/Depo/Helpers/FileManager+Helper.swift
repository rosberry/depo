//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

extension FileManager {

    @discardableResult
    func perform<T>(atPath path: String, _ action: () throws -> T) rethrows -> T {
        let currentPath = currentDirectoryPath
        defer {
            changeCurrentDirectoryPath(currentPath)
        }
        changeCurrentDirectoryPath(path)
        return try action()
    }

    func perform(atPath path: String, _ action: () throws -> Void) rethrows {
        let _: Void = try perform(atPath: path, action)
    }
}
