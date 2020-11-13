//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

struct SwiftPackage {

    private enum CodingKeys: String, CodingKey {
        case name
        case url
        case exactVersion
    }

    let name: String
    let url: URL
    let exactVersion: String
}

extension SwiftPackage: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let url = try container.decode(URL.self, forKey: .url)
        name = try container.decodeIfPresent(String.self, forKey: .name) ??
                   url.lastPathComponent.replacingOccurrences(of: ".git", with: "")
        self.url = url
        exactVersion = try container.decode(String.self, forKey: .name)
    }
}
