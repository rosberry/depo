//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import ArgumentParser

struct Pod {

    enum Kind {
        case common
        case builtFramework
        case unknown
    }

    enum Operator: String, Codable, HasDefault {
        case equal
        case greater
        case greaterOrEqual
        case lower
        case lowerOrEqual
        case compatible

        var symbol: String {
            switch self {
            case .equal:
                return "="
            case .greater:
                return ">"
            case .greaterOrEqual:
                return ">="
            case .lower:
                return "<"
            case .lowerOrEqual:
                return "<="
            case .compatible:
                return "~>"
            }
        }

        static let defaultValue: Operator = .equal
    }

    let name: String
    let version: Version<Operator>?
}

extension Pod: Codable {

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let slashCharacter = Character("/")
        name = try container.decode(String.self, forKey: .name).filter { character in
            character != slashCharacter
        }
        version = try container.decodeIfPresent(Version.self, forKey: .version)
    }
}
