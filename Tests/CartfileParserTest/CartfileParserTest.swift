//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import XCTest
import CartfileParser

final class CartfileParserTest: XCTestCase {

    private let bundle: Bundle = Bundle.module

    // the origin of this test can be found here:
    // https://github.com/Carthage/Carthage/blob/master/Tests/CarthageKitTests/CartfileSpec.swift
    func testCartfileParsing() {
        guard let url = bundle.url(forResource: "TestCartfile", withExtension: ""),
              let cartfile = try? Cartfile.from(file: url).get() else {
            XCTFail("bar TestCartfile")
            return
        }

        let reactiveCocoa = Dependency.gitHub("ReactiveCocoa/ReactiveCocoa")
        let mantle = Dependency.gitHub("Mantle/Mantle")
        let libextobjc = Dependency.gitHub("jspahrsummers/libextobjc")
        let xcconfigs = Dependency.gitHub("jspahrsummers/xcconfigs")
        let iosCharts = Dependency.gitHub("danielgindi/ios-charts.git")
        let errorTranslations = Dependency.gitHub("https://enterprise.local/ghe/desktop/git-error-translations")
        let errorTranslations2 = Dependency.git(URL(string: "https://enterprise.local/desktop/git-error-translations2.git"))
        let example1 = Dependency.gitHub("ExampleOrg/ExamplePrj1")
        let example2 = Dependency.gitHub("ExampleOrg/ExamplePrj2")
        let example3 = Dependency.gitHub("ExampleOrg/ExamplePrj3")
        let example4 = Dependency.gitHub("ExampleOrg/ExamplePrj4")

        let expectedDependencies: [Dependency: VersionSpecifier] = [
            reactiveCocoa: .atLeast(SemanticVersion(2, 3, 1)),
            mantle: .compatibleWith(SemanticVersion(1, 0, 0)),
            libextobjc: .exactly(SemanticVersion(0, 4, 1)),
            xcconfigs: .any,
            iosCharts: .any,
            errorTranslations: .any,
            errorTranslations2: .gitReference("development"),
            example1: .atLeast(SemanticVersion(3, 0, 2, preRelease: "pre")),
            example2: .exactly(SemanticVersion(3,
                                               0,
                                               2,
                                               preRelease: nil,
                                               buildMetadata: "build")),
            example3: .exactly(SemanticVersion(3, 0, 2)),
            example4: .gitReference("release#2")
        ]
        XCTAssertEqual(cartfile.dependencies, expectedDependencies)
    }
}