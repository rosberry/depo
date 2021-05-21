//
// Copyright © 2020 Rosberry. All rights reserved.
//

import PathKit

public extension Path {

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
