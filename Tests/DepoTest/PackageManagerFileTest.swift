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

    func expectNoThrow(_ test: @autoclosure () throws -> Void, _ file: StaticString, _ line: UInt) {
        do {
            try test()
        }
        catch {
            XCTFail(error.localizedDescription, file: file, line: line)
        }
    }

    var projectSettings: BuildSettings {
        .init(productName: "Test",
              swiftVersion: "test-swift-version",
              targetName: "TestTarget",
              codesigningFolderPath: nil,
              platform: .tvos,
              deploymentTarget: "test-deployment-target")
    }


    func compare<FileModel: CustomStringConvertible>(model: FileModel,
                                                     andLocalFile localFileName: String,
                                                     in bundle: Bundle = .init(for: Self.self)) throws {
        guard let url = bundle.url(forResource: localFileName, withExtension: "txt"),
              let data = try? Data(contentsOf: url),
              let string = String(data: data, encoding: .utf8) else {
            throw ComparisonError.badFile(name: localFileName)
        }
        let modelDescription = model.description
        if string != modelDescription {
            throw ComparisonError.notEqual(model: modelDescription, file: string)
        }
    }
}
