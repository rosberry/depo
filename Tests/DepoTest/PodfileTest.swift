//
// Copyright © 2020 Rosberry. All rights reserved.
//

import XCTest
import Foundation
import DepoCore

final class PodfileTest: XCTestCase, PackageManagerFileTest {

    func testPodfileWithNoDependencies() {
        let podfile = PodFile(buildSettings: projectSettings, pods: [])
        expectNoThrow(try compare(model: podfile, andLocalFile: "PodfileNoDeps", withLocalFileExt: ""), #file, #line)
    }

    func testPodfileWithDependencies() {
        let podfile = PodFile(buildSettings: projectSettings, pods: pods)
        expectNoThrow(try compare(model: podfile, andLocalFile: "PodfileWithDeps", withLocalFileExt: ""), #file, #line)
    }

    func testEmptyPodfileFromActualPodfile() {
        expectNoThrow(try {
            let parsedPodfile = try self.parsedPodfile(path: "PodfileNoDeps")
            let podfile = PodFile(buildSettings: projectSettings, pods: [])
            XCTAssertEqual(podfile.description, parsedPodfile.description)
        }(), #file, #line)
    }

    func testPodfileFromActualPodfile() {
        expectNoThrow(try {
            let parsedPodfile = try self.parsedPodfile(path: "PodfileWithDeps")
            let podfile = PodFile(buildSettings: projectSettings, pods: pods)
            XCTAssertEqual(podfile.description, parsedPodfile.description)
        }(), #file, #line)
    }

    private func parsedPodfile(path: String) throws -> PodFile {
        let podfileNoDepsURL = try fileURL(name: path, ext: "")
        let protocolPart = podfileNoDepsURL.scheme.map { "\($0)://" } ?? ""
        let processedURL = podfileNoDepsURL.absoluteString.replacingOccurrences(of: protocolPart, with: "")
        return try PodShellCommand().podfile(buildSettings: projectSettings, path: processedURL)
    }
}
