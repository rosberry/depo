//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import Files

public final class SwiftPackageShellCommand: ShellCommand {

    typealias SPVersionConstraint = VersionConstraint<SwiftPackage.Operator>

    public struct SPOutputWrapper: Codable {
        public let products: [Product]
        public let targets: [Target]
        public let dependencies: [Dependency]
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

    @discardableResult
    public func update(args: [String]) throws -> String {
        try shell(silent: "\(commandPath) package update \(args.spaceJoined)")
    }

    public func packageSwift(buildSettings: BuildSettings, path: String) throws -> PackageSwift {
        let packages = try swiftPackages(packageSwiftFilePath: path)
        return .init(projectBuildSettings: buildSettings, spmVersion: try spmVersion(), packages: packages)
    }

    public func packageSwift(buildSettings: BuildSettings, absolutePath: String) throws -> PackageSwift {
        let packages = try swiftPackages(packageSwiftFilePath: absolutePath)
        return .init(projectBuildSettings: buildSettings, spmVersion: try spmVersion(), packages: packages)
    }

    public func targetsOfSwiftPackage(at path: String) throws -> [String] {
        try jsonerOutput(at: path).products.map(by: \.targets).reduce([], +)
    }

    public func swiftPackages(packageSwiftFilePath: String) throws -> [SwiftPackage] {
        try swiftPackageByJsoner(packageSwiftFilePath: packageSwiftFilePath)
    }

    @discardableResult
    public func generateXcodeproj() throws -> String {
        try shell(silent: "\(commandPath) package generate-xcodeproj")
    }

    public func spmVersion() throws -> String {
        let output = try shell(silent: "\(commandPath) package --version")
        guard let keyRange = output.range(of: #"Swift Package Manager - Swift "#, options: .regularExpression),
              let valueRange = output[from: keyRange.upperBound].range(of: #"([^\s]+)"#, options: .regularExpression) else {
            return ""
        }
        return String(output[valueRange])
    }

    public func swiftPackageDump(at path: String) throws -> SPOutputWrapper {
        try jsonerOutput(at: path)
    }

    private func swiftPackageByJsoner(packageSwiftFilePath: String) throws -> [SwiftPackage] {
        try jsonerOutput(at: packageSwiftFilePath).dependencies.map { dependency in
            .init(name: dependency.name,
                  url: dependency.url,
                  versionConstraint: versionConstraint(from: dependency.requirement))
        }
    }

    private func jsonerOutput(at path: String, fmg: FileManager = .default) throws -> SPOutputWrapper {
        let output: String = try fmg.perform(atPath: path) {
            try shell(silent: "\(commandPath) package dump-package")
        }
        return try JSONDecoder().decode(SPOutputWrapper.self, from: output.data(using: .utf8) ?? Data())
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
        return string[openSquareBracketIndex..<closeSquareBracketIndex].filter { character in
            !character.isNewline
        }
    }

    private func products(from dependenciesArrayString: String) throws -> [String] {
        let regexp = #"/(\(([^()]|(?R))*\))/g"#
        let perlCode = #"my $text = '\#(dependenciesArrayString)'; while($text =~ \#(regexp)) { print("$1\n"); }"#
        let file = try Folder.current.createFile(at: "./products_regexp", contents: perlCode.data(using: .utf8)!)

        defer {
            try? file.delete()
        }

        let output = try shell(silent: "perl \(file.path)")
        return output.split(separator: Character("\n")).map { substrings in
            String(substrings)
        }
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

    private func versionConstraint(from req: SPOutputWrapper.Dependency.Requirement) -> SPVersionConstraint? {
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

    private func upToVersionConstraint(from requirement: SPOutputWrapper.Dependency.Requirement) -> SPVersionConstraint? {
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

public extension SwiftPackageShellCommand.SPOutputWrapper {
    public struct Dependency: Codable {
        public let  name: String?
        public let  url: URL
        public let  requirement: Requirement
    }

    public struct Target: Codable {

        public enum TypeEnum: String, Codable {
            case regular
            case test
        }

        public let name: String
        public let type: TypeEnum
        public let path: String?
    }

    public struct Product: Codable {
        public let name: String
        public let targets: [String]
    }
}

public extension SwiftPackageShellCommand.SPOutputWrapper.Dependency {
    public struct Requirement: Codable {

        public enum Kind: String, Codable {
            case range
            case exact
            case branch
            case revision
            case localPackage
        }

        public enum CodingKeys: String, CodingKey {
            case type
            case identifier
            case lowerBound
            case upperBound
        }

        public struct RangeModel: Codable {
            let lowerBound: String
            let upperBound: String
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let wrapper = try? container.decode([String: [RangeModel]].self),
               let range = wrapper.first?.value.first {
                self.type = .range
                self.identifier = nil
                self.lowerBound = range.lowerBound
                self.upperBound = range.upperBound
            }
            else {
                guard let wrapper = try container.decode([String: [String]].self).first,
                      let type = Kind(rawValue: wrapper.key),
                      let identifier = wrapper.value.first else {
                    throw DecodingError.typeMismatch(Requirement.self,
                                                     .init(codingPath: [], debugDescription: "Cannot parse Requirement model"))
                }
                self.type = type
                self.identifier = identifier
                self.lowerBound = nil
                self.upperBound = nil
            }
        }

        public let type: Kind
        public let identifier: String?
        public let lowerBound: String?
        public let upperBound: String?
    }
}
