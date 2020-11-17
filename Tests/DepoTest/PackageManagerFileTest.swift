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
              swiftVersion: "test-swift-version",
              targetName: "TestTarget",
              codesigningFolderPath: nil,
              platform: .tvos,
              deploymentTarget: "test-deployment-target")
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
        CarthageItem.Kind.allCases.reduce([CarthageItem]()) { result, kind in
            let ops: [CarthageItem.Operator?] = [nil] + CarthageItem.Operator.allCases
            return result + ops.enumerated().reduce([CarthageItem]()) { result, context in
                let (index, op) = context
                let version = op.map { op in
                    VersionConstraint<CarthageItem.Operator>(operation: op, value: "test-\(kind)-\(index + 1)-version")
                }
                return result + [CarthageItem(kind: kind, identifier: "test-\(kind)-\(index + 1)-identifier", versionConstraint: version)]
            }
        }
    }

    func compare<FileModel: CustomStringConvertible>(model: FileModel,
                                                     andLocalFile localFileName: String,
                                                     withLocalFileExt localFileExtension: String = "txt",
                                                     in bundle: Bundle = .init(for: Self.self)) throws {
        let fileContent = try self.fileContent(name: localFileName, ext: localFileExtension, bundle: bundle)
        let modelDescription = model.description
        if fileContent != modelDescription {
            throw ComparisonError.notEqual(model: modelDescription, file: fileContent)
        }
    }

    func fileContent(name: String, ext: String, bundle: Bundle = .init(for: Self.self)) throws -> String {
        guard let url = bundle.url(forResource: name, withExtension: ext),
              let data = try? Data(contentsOf: url),
              let string = String(data: data, encoding: .utf8) else {
            throw ComparisonError.badFile(name: "\(name).\(ext)")
        }
        return string
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
