//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import Files

public final class SwiftPackageShellCommand: ShellCommand {

    public enum Error: LocalizedError {
        case badUpdate
    }

    public func update() throws {
        if !shell("swift", "package", "update") {
            throw Error.badUpdate
        }
    }

    public func packageSwift(buildSettings: BuildSettings, path: String) throws -> PackageSwift {
        try packageSwift(buildSettings: buildSettings, file: try Folder.current.file(at: path))
    }

    public func packageSwift(buildSettings: BuildSettings, absolutePath: String) throws -> PackageSwift {
        try packageSwift(buildSettings: buildSettings, file: try File(path: absolutePath))
    }

    private func packageSwift(buildSettings: BuildSettings, file: File) throws -> PackageSwift {
        let content = try file.readAsString()
        guard let dependenciesContent = try dependenciesArray(from: content) else {
            return PackageSwift(projectBuildSettings: buildSettings, packages: [])
        }
        let products = try self.products(from: dependenciesContent)
        let packages = try products.compactMap { productString in
            try swiftPackage(from: productString)
        }
        return .init(projectBuildSettings: buildSettings, packages: packages)
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
}
