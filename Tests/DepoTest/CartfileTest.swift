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

    func testEmptyCartfileFromActualCartfile() {
        expectNoThrow(try {
            let cartfileNoDepsURL = try fileURL(name: "CartfileNoDeps", ext: "txt")
            let parsedCartfile = try CarthageShellCommand(commandPath: "carthage").cartfile(url: cartfileNoDepsURL)
            let cartfile = Cartfile(items: [])
            XCTAssertEqual(cartfile.description, parsedCartfile.description)
        }(), #file, #line)
    }

    func testCartfileFromActualCartfile() {
        expectNoThrow(try {
            let cartfileNoDepsURL = try fileURL(name: "CartfileWithDeps", ext: "txt")
            let parsedCartfile = try CarthageShellCommand(commandPath: "carthage").cartfile(url: cartfileNoDepsURL)
            let cartfile = Cartfile(items: carts)
            let parsedCartfileLines = lines(from: parsedCartfile.description)
            let cartfileLines = lines(from: cartfile.description)
            let parsedCartfileLinesSet = Set(parsedCartfileLines)
            let cartfileLinesSet = Set(cartfileLines)
            XCTAssertEqual(parsedCartfileLines.count, parsedCartfileLinesSet.count)
            XCTAssertEqual(cartfileLines.count, cartfileLinesSet.count)
            XCTAssertEqual(cartfileLinesSet, parsedCartfileLinesSet)
        }(), #file, #line)
    }

    private func lines(from string: String) -> [String] {
        string.trimmingCharacters(in: .whitespacesAndNewlines).split(separator: Character("\n")).map { String($0) }
    }
}
