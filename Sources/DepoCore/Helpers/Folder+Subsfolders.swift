//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import Files

extension Folder {
    var allSubfolders: [Folder] {
        Array(subfolders) + subfolders.reduce([]) { result, subfolder in
            result + subfolder.allSubfolders
        }
    }

    func copyContents(to folder: Folder) throws {
        try files.copy(to: folder)
        try subfolders.copy(to: folder)
    }

    func deleteContents() throws {
        try files.delete()
        try subfolders.delete()
    }
}

extension Folder.ChildSequence {
    func copy(to folder: Folder) throws {
        try forEach { try $0.copy(to: folder) }
    }
}
