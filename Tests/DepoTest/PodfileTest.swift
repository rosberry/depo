//
// Copyright © 2020 Rosberry. All rights reserved.
//

import XCTest
import Foundation
import DepoCore

final class PodfileTest: XCTestCase, PackageManagerFileTest {

    func testPodfileWithNoDependencies() {
        let podfile = PodFile(buildSettings: projectSettings, pods: [])
        expectNoThrow(try compare(model: podfile, andLocalFile: "PodfileNoDeps"), #file, #line)
    }

    func testPodfileWithDependencies() {
        let podfile = PodFile(buildSettings: projectSettings, pods: pods)
        expectNoThrow(try compare(model: podfile, andLocalFile: "PodfileWithDeps"), #file, #line)
    }
}
