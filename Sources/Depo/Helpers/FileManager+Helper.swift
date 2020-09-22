//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

extension FileManager {

    @discardableResult
    func operate<T>(in path: String, _ action: () throws -> T) rethrows -> T {
        let currentPath = currentDirectoryPath
        defer {
            changeCurrentDirectoryPath(currentPath)
        }
        changeCurrentDirectoryPath(path)
        return try action()
    }

    func operate(in path: String, _ action: () throws -> Void) rethrows {
        let _: Void = try operate(in: path, action)
    }
}
