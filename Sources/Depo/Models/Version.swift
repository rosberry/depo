//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

struct Version<Operator: Codable & HasDefault>: Codable {
    private enum CodingKeys: String, CodingKey {
        case value
        case operation
    }

    let value: String
    let operation: Operator

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        value = try container.decode(String.self, forKey: .value)
        operation = try container.decodeIfPresent(Operator.self, forKey: .operation) ?? Operator.defaultValue
    }
}
