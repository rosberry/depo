//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import XCTest
import DepoCore

final class CartfileTest: XCTestCase, PackageManagerFileTest {

    func testCartfileWithNoDeps() {
        expectNoThrow(try compare(model: Cartfile(items: []), andLocalFile: "CartfileNoDeps"), #file, #line)
    }

    func testCartfileWithDeps() {
        expectNoThrow(try compare(model: Cartfile(items: carts), andLocalFile: "CartfileWithDeps"), #file, #line)
    }
}
