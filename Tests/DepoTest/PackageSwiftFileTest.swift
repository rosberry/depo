//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import XCTest
import DepoCore

final class PackageSwiftFileTest: XCTestCase, PackageManagerFileTest {

    func testWithNoDeps() {
        do {
            let packageSwift = PackageSwift(projectBuildSettings: projectSettings, items: [])
            try compare(model: packageSwift, andLocalFile: "PackageSwiftNoDeps")
        }
        catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testWithDeps() {
        do {
            let packages = [
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
                             versionConstraint: .init(operation: .revision, value: "test-package-5-commit-hash"))]
            let packageSwift = PackageSwift(projectBuildSettings: projectSettings, items: packages)
            try compare(model: packageSwift, andLocalFile: "PackageSwiftWithDeps")
        }
        catch {
            XCTFail(error.localizedDescription)
        }
    }
}
