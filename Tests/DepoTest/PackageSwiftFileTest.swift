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
}
