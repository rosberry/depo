//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

public enum XcodeList {

    public struct Workspace: Codable {
        public let name: String
        public let schemes: [String]
    }

    public struct Project: Codable {
        public let name: String
        public let configurations: [String]
        public let schemes: [String]
        public let targets: [String]
    }
}
