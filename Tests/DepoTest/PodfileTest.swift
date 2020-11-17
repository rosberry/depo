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
        let pods = Pod.Operator.allCases.enumerated().map { index, versionOperator -> Pod in
            let name = "test-pod-\(index + 1)"
            return Pod(name: name, versionConstraint: .init(operation: versionOperator, value: "\(name)-version"))
        }
        let podfile = PodFile(buildSettings: projectSettings, pods: pods)
        expectNoThrow(try compare(model: podfile, andLocalFile: "PodfileWithDeps"), #file, #line)
    }
}
