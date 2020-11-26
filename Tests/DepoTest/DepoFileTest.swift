//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import XCTest
import DepoCore
import Yams

final class DepoFileTest: XCTestCase, PackageManagerFileTest {

    enum Error: LocalizedError {
        case badData
    }

    func testEmptyDepofile() {
        expectNoThrow(try {
            let depoFileNoDeps = try fileContent(name: "DepofileNoDeps", ext: "")
            guard let depoFileData = depoFileNoDeps.data(using: .utf8) else {
                throw Error.badData
            }
            let depoFile: Depofile = try YAMLDecoder().decode(from: depoFileData)
            guard depoFile.swiftPackages.isEmpty,
                  depoFile.carts.isEmpty,
                  depoFile.pods.isEmpty else {
                let depoFileString = try YAMLEncoder().encode(depoFile)
                throw ComparisonError.notEqual(model: depoFileString, file: depoFileNoDeps)
            }
        }(), #file, #line)
    }

    func testNotEmptyDepofile() {
        expectNoThrow(try {
            let depofileWithDeps = try fileContent(name: "DepofileWithDeps", ext: "").trimmingCharacters(in: .whitespacesAndNewlines)
            guard let depofileData = depofileWithDeps.data(using: .utf8) else {
                throw Error.badData
            }
            let depofile: Depofile = try YAMLDecoder().decode(from: depofileData)
            guard depofile.swiftPackages == swiftPackages,
                  depofile.carts == carts,
                  depofile.pods == pods else {
                let depoFileString = try YAMLEncoder().encode(depofile).trimmingCharacters(in: .whitespacesAndNewlines)
                throw ComparisonError.notEqual(model: depoFileString, file: depofileWithDeps)
            }
        }(), #file, #line)
    }
}
