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
        let carthageItems = CarthageItem.Kind.allCases.reduce([CarthageItem]()) { result, kind in
            let ops: [CarthageItem.Operator?] = [nil] + CarthageItem.Operator.allCases
            return result + ops.enumerated().reduce([CarthageItem]()) { result, context in
                let (index, op) = context
                let version = op.map { op in
                    VersionConstraint<CarthageItem.Operator>(operation: op, value: "test-\(kind)-\(index + 1)-version")
                }
                return result + [CarthageItem(kind: kind, identifier: "test-\(kind)-\(index + 1)-identifier", versionConstraint: version)]
            }
        }
        let cartfile = Cartfile(items: carthageItems)
        expectNoThrow(try compare(model: cartfile, andLocalFile: "CartfileWithDeps"), #file, #line)
    }
}
