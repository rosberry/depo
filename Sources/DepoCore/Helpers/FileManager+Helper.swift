//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

extension FileManager {

    enum Error: Swift.Error {
        case notExist(path: String)
    }

    @discardableResult
    func perform<T>(atPath path: String, _ action: () throws -> T) throws -> T {
        var bool = ObjCBool(true)
        guard fileExists(atPath: path, isDirectory: &bool) else {
            throw Error.notExist(path: path)
        }
        let currentPath = currentDirectoryPath
        defer {
            changeCurrentDirectoryPath(currentPath)
        }
        changeCurrentDirectoryPath(path)
        return try action()
    }
}
