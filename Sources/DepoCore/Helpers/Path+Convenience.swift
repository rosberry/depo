//
// Copyright © 2020 Rosberry. All rights reserved.
//

import PathKit

public extension Path {

    var folder: Path? {
        guard !isDirectory else {
            return nil
        }
        var output = description
        output.removeLast(lastComponent.count)
        return Path(output)
    }

    func overwrite(_ path: Path) throws {
        try path.deleteIfExists()
        try move(path)
    }

    func deleteIfExists() throws {
        if exists {
            try delete()
        }
    }
}
