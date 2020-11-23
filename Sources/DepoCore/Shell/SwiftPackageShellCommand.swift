//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import Files

public final class SwiftPackageShellCommand: ShellCommand {

    private struct JsonerOutputWrapper: Codable {
        struct Dependency: Codable {

            struct Requirement: Codable {

                enum Kind: String, Codable {
                    case range
                    case exact
                    case branch
                    case revision
                    case localPackage
                }

                private enum CodingKeys: String, CodingKey {
                    case type
                    case identifier
                    case lowerBound
                    case upperBound
                }

                let type: Kind
                let identifier: String?
                let lowerBound: String?
                let upperBound: String?
            }

            let name: String?
            let url: URL
            let requirement: Requirement
        }

        let dependencies: [Dependency]
    }

    private struct Version {
        let major: Int
        let minor: Int
        let patch: Int

        init?(string: String) {
            let splitted = string.split(separator: Character(".")).compactMap { sequence in
                Int(sequence)
            }
            guard splitted.count == 3 else {
                return nil
            }
            major = splitted[0]
            minor = splitted[1]
            patch = splitted[2]
        }
    }

    public enum Error: LocalizedError {
        case badUpdate
    }

    public func update() throws {
        if !shell("swift", "package", "update") {
            throw Error.badUpdate
        }
    }

    public func packageSwift(buildSettings: BuildSettings, path: String) throws -> PackageSwift {
        let packages = try swiftPackages(packageSwiftFilePath: path)
        return .init(projectBuildSettings: buildSettings, packages: packages)
    }

    public func packageSwift(buildSettings: BuildSettings, absolutePath: String) throws -> PackageSwift {
        let packages = try swiftPackages(packageSwiftFilePath: absolutePath)
        return .init(projectBuildSettings: buildSettings, packages: packages)
    }

    public func swiftPackages(packageSwiftFilePath: String) throws -> [SwiftPackage] {
        try swiftPackageByJsoner(packageSwiftFilePath: packageSwiftFilePath)
    }

    private func swiftPackageByJsoner(packageSwiftFilePath: String) throws -> [SwiftPackage] {
        let output: Shell.IO = try shell("jsoner", "package-swift", packageSwiftFilePath)
        let model = try JSONDecoder().decode(JsonerOutputWrapper.self, from: output.stdOut.data(using: .utf8) ?? Data())
        return model.dependencies.map { dependency in
            .init(name: dependency.name,
                  url: dependency.url,
                  versionConstraint: versionConstraint(from: dependency.requirement))
        }
    }

    private func swiftPackagesByRegex(file: File) throws -> [SwiftPackage] {
        let content = try file.readAsString()
        guard let dependenciesContent = try dependenciesArray(from: content) else {
            return []
        }
        let products = try self.products(from: dependenciesContent)
        return try products.compactMap { productString in
            try swiftPackage(from: productString)
        }
    }

    private func dependenciesArray(from string: String) throws -> String? {
        guard let dependenciesIndex = string.range(of: "dependencies:")?.upperBound else {
            return nil
        }
        let lastIndex = string.index(string.startIndex, offsetBy: string.count - 1)
        let contentFromDependencies = string[dependenciesIndex..<lastIndex]
        guard let openSquareBracketIndex = contentFromDependencies.range(of: "[")?.upperBound else {
            return nil
        }
        let contentFromOpenBracket = string[openSquareBracketIndex..<lastIndex]
        guard let closeSquareBracketIndex = contentFromOpenBracket.range(of: "]")?.lowerBound else {
            return nil
        }
        return string[openSquareBracketIndex..<closeSquareBracketIndex].filter { !$0.isNewline }
    }

    private func products(from dependenciesArrayString: String) throws -> [String] {
        let regexp = #"/(\(([^()]|(?R))*\))/g"#
        let perlCode = #"my $text = '\#(dependenciesArrayString)'; while($text =~ \#(regexp)) { print("$1\n"); }"#
        let file = try Folder.current.createFile(at: "./perl_hello", contents: perlCode.data(using: .utf8)!)

        defer {
            try? file.delete()
        }

        let output: Shell.IO = try shell("perl", file.path)
        return output.stdOut.split(separator: Character("\n")).map { String($0) }
    }

    private func swiftPackage(from string: String) throws -> SwiftPackage? {
        let strings = try egrep(string, pattern: #"(["'])(?:(?=(\\?))\2.)*?\1"#)
        let name: String?
        let url: URL?
        let version: String
        switch strings.count {
        case 3:
            name = strings[0]
            url = URL(string: strings[1])
            version = strings[2]
        case 2:
            name = nil
            url = URL(string: strings[0])
            version = strings[1]
        default:
            return nil
        }
        guard let noNilUrl = url else {
            return nil
        }
        return .init(name: name, url: noNilUrl, versionConstraint: .init(operation: .defaultValue, value: version))
    }

    private func egrep(_ string: String, pattern: String) throws -> [String] {
        let range = NSRange(location: 0, length: string.utf16.count)
        let regexp = try NSRegularExpression(pattern: pattern)
        let matches = regexp.matches(in: string, range: range)
        return matches.compactMap { result -> String? in
            guard let matchingRange = Range(result.range, in: string) else {
                return nil
            }
            return String(string[matchingRange]).replacingOccurrences(of: "\"", with: "")
        }
    }

    private func versionConstraint(from req: JsonerOutputWrapper.Dependency.Requirement) -> VersionConstraint<SwiftPackage.Operator>? {
        switch req.type {
        case .range:
            return upToVersionConstraint(from: req)
        case .exact:
            return .init(operation: .exact, value: req.identifier ?? "")
        case .branch:
            return .init(operation: .branch, value: req.identifier ?? "")
        case .revision:
            return .init(operation: .revision, value: req.identifier ?? "")
        case .localPackage:
            return nil
        }
    }

    private func upToVersionConstraint(from requirement: JsonerOutputWrapper.Dependency.Requirement) -> VersionConstraint<SwiftPackage.Operator>? {
        guard let lowerBound = requirement.lowerBound,
              let upperBound = requirement.upperBound,
              let lowerBoundVersion = Version(string: lowerBound),
              let upperBoundVersion = Version(string: upperBound) else {
            return nil
        }
        return .init(operation: upToVersionOperator(lowerVersion: lowerBoundVersion, upperVersion: upperBoundVersion), value: lowerBound)
    }

    private func upToVersionOperator(lowerVersion: Version, upperVersion: Version) -> SwiftPackage.Operator {
        if lowerVersion.major + 1 == upperVersion.major {
            return .upToNextMajor
        }
        else {
            return .upToNextMinor
        }
    }
}
