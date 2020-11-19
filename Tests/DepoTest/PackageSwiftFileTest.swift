//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import XCTest
import DepoCore

final class PackageSwiftFileTest: XCTestCase, PackageManagerFileTest {

    func testWithNoDeps() {
        let packageSwift = PackageSwift(projectBuildSettings: projectSettings, items: [])
        expectNoThrow(try compare(model: packageSwift, andLocalFile: "PackageSwiftNoDeps"), #file, #line)
    }

    func testWithDeps() {
        let packageSwift = PackageSwift(projectBuildSettings: projectSettings, items: swiftPackages)
        expectNoThrow(try compare(model: packageSwift, andLocalFile: "PackageSwiftWithDeps"), #file, #line)
    }

    func testEmptyActualPackageSwiftToModel() {
        expectNoThrow(try {
            let url = try fileURL(name: "PackageSwiftNoDeps", ext: "txt")
            let parsedPackageSwift = try self.parsedPackageSwift(path: url.absoluteStringWithoutScheme)
            let packageSwift = PackageSwift(projectBuildSettings: projectSettings, items: [])
            XCTAssertEqual(packageSwift.description, parsedPackageSwift.description)
        }(), #file, #line)
    }

    func testActualPackageSwiftToModel() {
        expectNoThrow(try {
            let url = try fileURL(name: "PackageSwiftWithDeps", ext: "txt")
            let parsedPackageSwift = try self.parsedPackageSwift(path: url.absoluteStringWithoutScheme)
            let packageSwift = PackageSwift(projectBuildSettings: projectSettings, items: swiftPackages)
            XCTAssertEqual(packageSwift.description, parsedPackageSwift.description)
        }(), #file, #line)
    }

    private func parsedPackageSwift(path: String) throws -> PackageSwift {
        try SwiftPackageShellCommand().packageSwift(buildSettings: projectSettings, absolutePath: path)
    }
}
