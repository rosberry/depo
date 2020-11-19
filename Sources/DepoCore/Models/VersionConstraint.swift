//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

#warning("make it expressible by string literal to now create object with value field for it in Depofile")
public struct VersionConstraint<Operator: Codable & HasDefaultValue>: Codable {

    private enum CodingKeys: String, CodingKey {
        case operation
        case value
    }

    public let operation: Operator
    public let value: String

    public init(operation: Operator, value: String) {
        self.operation = operation
        self.value = value
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        value = try container.decode(String.self, forKey: .value)
        operation = try container.decodeIfPresent(Operator.self, forKey: .operation) ?? Operator.defaultValue
    }
}

extension VersionConstraint: Equatable where Operator: Equatable {}
extension VersionConstraint: Hashable where Operator: Hashable {}
