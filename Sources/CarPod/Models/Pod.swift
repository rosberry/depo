//
// Copyright (c) 2020 ___FULLUSERNAME___. All rights reserved.
//

import Foundation
import ArgumentParser

struct Pod {

    struct Version: Codable {

        enum Operator: String, Codable, ExpressibleByArgument {
            case equal
            case greater
            case greaterOrEqual
            case lower
            case lowerOrEqual
            case tilda

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
                case .tilda:
                    return "~>"
                }
            }
        }

        private enum CodingKeys: String, CodingKey {
            case value
            case operation
        }

        let value: String
        let operation: Operator

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            value = try container.decode(String.self, forKey: .value)
            operation = try container.decodeIfPresent(Operator.self, forKey: .operation) ?? .equal
        }
    }

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
