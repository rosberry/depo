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

    public enum Operator: String, Codable, HasDefaultValue, Hashable {
        case exact
        case upToNextMinor
        case upToNextMajor
        case branch
        case revision

        public static let defaultValue: SwiftPackage.Operator = .exact
    }

    public let name: String
    public let url: URL
    public let versionConstraint: VersionConstraint<Operator>?
    public var directoryName: String {
        url.lastPathComponentWithoutGitExtension
    }

    public init(name: String?, url: URL, versionConstraint: VersionConstraint<Operator>?) {
        self.name = name ?? url.lastPathComponentWithoutGitExtension
        self.url = url
        self.versionConstraint = versionConstraint
    }
}

extension SwiftPackage: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let name = try container.decodeIfPresent(String.self, forKey: .name)
        let url = try container.decode(URL.self, forKey: .url)
        let versionConstraint = try container.decode(VersionConstraint<Operator>.self, forKey: .versionConstraint)
        self.init(name: name, url: url, versionConstraint: versionConstraint)
    }
}

extension SwiftPackage: Hashable {
}

fileprivate extension URL {
    var lastPathComponentWithoutGitExtension: String {
        lastPathComponent.replacingOccurrences(of: ".git", with: "")
    }
}
