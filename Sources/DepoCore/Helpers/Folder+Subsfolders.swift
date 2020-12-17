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
}
