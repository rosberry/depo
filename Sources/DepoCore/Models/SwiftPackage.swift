//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

public struct SwiftPackage {

    private enum CodingKeys: String, CodingKey {
        case name
        case url
        case versionConstraint = "version"
    }

    public enum Operator: String, Codable, HasDefaultValue {
        case exact
        case upToNextMinor
        case upToNextMajor
        case branch
        case revision

        public static let defaultValue: SwiftPackage.Operator = .exact
    }

    public let name: String
    public let url: URL
    public let versionConstraint: VersionConstraint<Operator>
}

extension SwiftPackage: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let url = try container.decode(URL.self, forKey: .url)
        name = try container.decodeIfPresent(String.self, forKey: .name) ??
                   url.lastPathComponent.replacingOccurrences(of: ".git", with: "")
        self.url = url
        versionConstraint = try container.decode(VersionConstraint<Operator>.self, forKey: .versionConstraint)
    }
}
