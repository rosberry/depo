//
// Copyright (c) 2020 ___FULLUSERNAME___. All rights reserved.
//

import Foundation
import ArgumentParser

struct InstallCarthageItems: ParsableCommand {

    enum CustomError: LocalizedError {
        case badCartfile(path: String)
        case badCarthageUpdate
    }

    let carthageItems: [CarthageItem]?

    init() {
        self.carthageItems = nil
    }

    init(carthageItems: [CarthageItem]) {
        self.carthageItems = carthageItems
    }

    func run() throws {
        let carthageItems = try self.carthageItems ?? CarPodfile().carts
        let path = FileManager.default.currentDirectoryPath
        let cartfilePath = path + "/Cartfile"

        try createCartfile(at: cartfilePath, with: carthageItems)
        try carthageUpdate()
    }

    private func createCartfile(at cartfilePath: String, with items: [CarthageItem]) throws {
        let content = Cartfile(items: items).description.data(using: .utf8)
        if !FileManager.default.createFile(atPath: cartfilePath, contents: content) {
            throw CustomError.badCartfile(path: cartfilePath)
        }
    }

    private func carthageUpdate() throws {
        if shell("carthage", "update", "--platform", "ios") != 0 {
            throw CustomError.badCarthageUpdate
        }
    }
}
