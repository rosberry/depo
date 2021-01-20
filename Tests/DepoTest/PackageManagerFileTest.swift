//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import DepoCore
import XCTest

enum ComparisonError: LocalizedError {
    case badFile(name: String)
    case notEqual(model: String, file: String)

    var errorDescription: String? {
        switch self {
        case let .badFile(name):
            return "unable to get file \(name) content"
        case let .notEqual(model, file):
            return """
                   contents aren't equal
                   model:
                   ====================
                   \(model)
                   ====================

                   file:
                   ====================
                   \(file)
                   ====================
                   """
        }
    }
}

protocol PackageManagerFileTest: class {

}

extension PackageManagerFileTest {

    var projectSettings: BuildSettings {
        .init(productName: "Test",
              swiftVersion: "test-xcode-swift-version",
              targetName: "TestTarget",
              codesigningFolderPath: nil,
              platform: .tvos,
              deploymentTarget: "test-deployment-target")
    }

    var spmVersion: String {
        "test-swift-version"
    }

    var pods: [Pod] {
        let ops = Pod.Operator.allCases + [nil]
        return ops.enumerated().map { index, op -> Pod in
            let name = "test-pod-\(index + 1)"
            return Pod(name: name, versionConstraint: op.map { op in
                .init(operation: op, value: "\(name)-version")
            })
        }
    }

    var swiftPackages: [SwiftPackage] {
        [
            SwiftPackage(name: "test-package-1",
                         url: URL(string: "file://test-package-1")!,
                         versionConstraint: .init(operation: .exact, value: "0.0.1")),
            SwiftPackage(name: "test-package-2",
                         url: URL(string: "file://test-package-2")!,
                         versionConstraint: .init(operation: .upToNextMinor, value: "0.1.0")),
            SwiftPackage(name: "test-package-3",
                         url: URL(string: "file://test-package-3")!,
                         versionConstraint: .init(operation: .upToNextMajor, value: "0.1.1")),
            SwiftPackage(name: "test-package-4",
                         url: URL(string: "file://test-package-4")!,
                         versionConstraint: .init(operation: .branch, value: "test-package-4-branch")),
            SwiftPackage(name: "test-package-5",
                         url: URL(string: "file://test-package-5")!,
                         versionConstraint: .init(operation: .revision, value: "test-package-5-commit-hash"))
        ]
    }

    var carts: [CarthageItem] {
        [CarthageItem(kind: .binary, identifier: "file://test-binary-1-identifier", versionConstraint: nil),
         CarthageItem(kind: .binary, identifier: "file://test-binary-2-identifier", versionConstraint: .init(operation: .equal, value: "0.0.0")),
         CarthageItem(kind: .binary,
                      identifier: "file://test-binary-3-identifier",
                      versionConstraint: .init(operation: .greaterOrEqual, value: "0.0.1")),
         CarthageItem(kind: .binary,
                      identifier: "file://test-binary-4-identifier",
                      versionConstraint: .init(operation: .compatible, value: "0.1.0")),
         CarthageItem(kind: .binary, identifier: "file://test-binary-5-identifier", versionConstraint: nil),
         CarthageItem(kind: .github, identifier: "test-github-1-identifier", versionConstraint: nil),
         CarthageItem(kind: .github, identifier: "test-github-2-identifier", versionConstraint: .init(operation: .equal, value: "0.1.1")),
         CarthageItem(kind: .github,
                      identifier: "test-github-3-identifier",
                      versionConstraint: .init(operation: .greaterOrEqual, value: "1.0.0")),
         CarthageItem(kind: .github,
                      identifier: "test-github-4-identifier",
                      versionConstraint: .init(operation: .compatible, value: "1.0.1")),
         CarthageItem(kind: .github,
                      identifier: "test-github-5-identifier",
                      versionConstraint: .init(operation: .gitReference, value: "test-github-5-git-reference")),
         CarthageItem(kind: .git, identifier: "test-git-1-identifier", versionConstraint: nil),
         CarthageItem(kind: .git, identifier: "test-git-2-identifier", versionConstraint: .init(operation: .equal, value: "1.1.0")),
         CarthageItem(kind: .git,
                      identifier: "test-git-3-identifier",
                      versionConstraint: .init(operation: .greaterOrEqual, value: "1.1.1")),
         CarthageItem(kind: .git, identifier: "test-git-4-identifier", versionConstraint: .init(operation: .compatible, value: "2.2.2")),
         CarthageItem(kind: .git,
                      identifier: "test-git-5-identifier",
                      versionConstraint: .init(operation: .gitReference, value: "test-git-5-git-reference"))]
    }

    func compare<FileModel: CustomStringConvertible>(model: FileModel,
                                                     andLocalFile localFileName: String,
                                                     withLocalFileExt localFileExtension: String = "txt",
                                                     in bundle: Bundle = .module) throws {
        let fileContent = try self.fileContent(name: localFileName, ext: localFileExtension, bundle: bundle)
        let modelDescription = model.description
        if fileContent != modelDescription {
            throw ComparisonError.notEqual(model: modelDescription, file: fileContent)
        }
    }

    func fileContent(name: String, ext: String, bundle: Bundle = .module) throws -> String {
        let url = try fileURL(name: name, ext: ext, bundle: bundle)
        guard let data = try? Data(contentsOf: url),
              let string = String(data: data, encoding: .utf8) else {
            throw ComparisonError.badFile(name: "\(name).\(ext)")
        }
        return string
    }

    func fileURL(name: String, ext: String, bundle: Bundle = .module) throws -> URL {
        guard let url = bundle.url(forResource: name, withExtension: ext) else {
            throw ComparisonError.badFile(name: "\(name).\(ext)")
        }
        return url
    }

    func expectNoThrow<T>(_ test: @autoclosure () throws -> T, _ file: StaticString, _ line: UInt) -> T? {
        do {
            return try test()
        }
        catch {
            XCTFail(error.localizedDescription, file: file, line: line)
            return nil
        }
    }

    func expectNoThrow(_ test: @autoclosure () throws -> Void, _ file: StaticString, _ line: UInt) {
        do {
            try test()
        }
        catch {
            XCTFail(error.localizedDescription, file: file, line: line)
        }
    }
}
