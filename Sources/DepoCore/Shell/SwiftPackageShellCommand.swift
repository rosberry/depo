//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import Files

public final class SwiftPackageShellCommand: ShellCommand {

    typealias SPVersionConstraint = VersionConstraint<SwiftPackage.Operator>

    fileprivate struct SPOutputWrapper: Codable {
        let products: [Product]
        let targets: [Target]
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

    @discardableResult
    public func update(args: [String]) throws -> Shell.IO {
        try shell("\(commandPath) package update \(args.spaceJoined)")
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
    public func generateXcodeproj() throws -> Shell.IO {
        try shell("\(commandPath) package generate-xcodeproj")
    }

    public func spmVersion() throws -> String {
        let swiftVersionOutput: Shell.IO = try shell("\(commandPath) package --version")
        let output = swiftVersionOutput.stdOut
        guard let keyRange = output.range(of: #"Swift Package Manager - Swift "#, options: .regularExpression),
              let valueRange = output[from: keyRange.upperBound].range(of: #"([^\s]+)"#, options: .regularExpression) else {
            return ""
        }
        return String(output[valueRange])
    }

    private func swiftPackageByJsoner(packageSwiftFilePath: String) throws -> [SwiftPackage] {
        try jsonerOutput(at: packageSwiftFilePath).dependencies.map { dependency in
            .init(name: dependency.name,
                  url: dependency.url,
                  versionConstraint: versionConstraint(from: dependency.requirement))
        }
    }

    private func jsonerOutput(at path: String, fmg: FileManager = .default) throws -> SPOutputWrapper {
        let output: Shell.IO = try fmg.perform(atPath: path) {
            try shell("\(commandPath) package dump-package")
        }
        return try JSONDecoder().decode(SPOutputWrapper.self, from: output.stdOut.data(using: .utf8) ?? Data())
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

        let output: Shell.IO = try shell("perl \(file.path)")
        return output.stdOut.split(separator: Character("\n")).map { substrings in
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

extension SwiftPackageShellCommand.SPOutputWrapper {
    fileprivate struct Dependency: Codable {
        let name: String?
        let url: URL
        let requirement: Requirement
    }

    fileprivate struct Target: Codable {

        enum TypeEnum: String, Codable {
            case regular
            case test
        }

        let name: String
        let type: TypeEnum
    }

    fileprivate struct Product: Codable {
        let name: String
        let targets: [String]
    }
}

extension SwiftPackageShellCommand.SPOutputWrapper.Dependency {
    fileprivate struct Requirement: Codable {

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

        private struct RangeModel: Codable {
            let lowerBound: String
            let upperBound: String
        }

        init(from decoder: Decoder) throws {
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

        let type: Kind
        let identifier: String?
        let lowerBound: String?
        let upperBound: String?
    }
}
