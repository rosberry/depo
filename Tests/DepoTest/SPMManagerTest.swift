//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import XCTest
import DepoCore

final class SPMManagerTest: XCTestCase {

    func testPackageSwiftFileGeneration() {
        let depofile = Depofile(pods: [], carts: [], swiftPackages: [])
        print(depofile)
    }
}
