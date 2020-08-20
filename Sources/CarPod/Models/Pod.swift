//
// Copyright (c) 2020 ___FULLUSERNAME___. All rights reserved.
//

import Foundation

struct Pod {

    let name: String
    let version: Version?
}

extension Pod: Codable {

    private enum CodingKeys: String, CodingKey {
        case name = "name"
        case version
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let slashCharacter = Character("/")
        name = try container.decode(String.self, forKey: .name).filter { character in
            character != slashCharacter
        }
        version = try container.decodeIfPresent(Version.self, forKey: .version)
    }
}
