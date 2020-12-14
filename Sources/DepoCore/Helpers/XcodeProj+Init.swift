//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import XcodeProj
import PathKit

public extension XcodeProj {

    enum Error: Swift.Error {
        case noXcodeProjects
        case multipleXcodeProjects
    }

    convenience init() throws {
        let xcodeProjects = Path.current.glob("*.xcodeproj")
        print(xcodeProjects)
        guard let firstXcodeProject = xcodeProjects.first else {
            throw Error.noXcodeProjects
        }
        print(firstXcodeProject)
        guard xcodeProjects.count == 1 else {
            throw Error.multipleXcodeProjects
        }
        try self.init(path: firstXcodeProject)
    }
}