//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import ArgumentParser

public struct CarthageItem: Codable {

    private enum CodingKeys: String, CodingKey {
        case kind
        case identifier
        case versionConstraint = "version"
    }

    public enum Kind: String, Codable, CaseIterable, Hashable {
        case binary
        case github
        case git
    }

    public enum Operator: String, Codable, HasDefaultValue, CaseIterable, Hashable {
        case equal
        case greaterOrEqual
        case compatible
        case gitReference

        var symbol: String {
            switch self {
            case .equal:
                return "=="
            case .greaterOrEqual:
                return ">="
            case .compatible:
                return "~>"
            case .gitReference:
                return ""
            }
        }
        public static let defaultValue: Operator = .equal
    }

    public let kind: Kind
    public let identifier: String
    public let versionConstraint: VersionConstraint<Operator>?

    public init(kind: Kind, identifier: String, versionConstraint: VersionConstraint<Operator>?) {
        self.kind = kind
        self.identifier = identifier
        self.versionConstraint = versionConstraint
    }
}

extension CarthageItem: Hashable {}

extension CarthageItem: CustomStringConvertible {
    public var description: String {
        "\(kind.rawValue) \"\(identifier)\"\(versionDescription)"
    }

    private var versionDescription: String {
        guard let versionConstraint = versionConstraint else {
            return ""
        }
        switch versionConstraint.operation {
        case .gitReference:
            return " \"\(versionConstraint.value)\""
        default:
            return " \(versionConstraint.operation.symbol) \(versionConstraint.value)"
        }
    }
}
