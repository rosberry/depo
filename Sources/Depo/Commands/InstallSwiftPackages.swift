//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import ArgumentParser

final class InstallSwiftPackages: ParsableCommand {

    enum CustomError: LocalizedError {
        case badPackageSwiftFile(path: String)
    }

    static let configuration: CommandConfiguration = .init(commandName: "swift-package-install")

    @OptionGroup()
    private(set) var options: Options

    private let packages: [SwiftPackage]?
    private let shell: Shell = .init()

    init() {
        self.packages = nil
    }

    init(packages: [SwiftPackage]) {
        self.packages = packages
    }

    func run() throws {
        let packages = try self.packages ?? CarPodfile(decoder: options.carpodFileType.decoder).swiftPackages
        try createPackageSwiftFile(at: "./Package.swift", with: packages)
    }

    private func createPackageSwiftFile(at filePath: String, with packages: [SwiftPackage]) throws {
        let buildSettings = try BuildSettings(targetName: nil, shell: shell)
        let content = PackageSwift(projectBuildSettings: buildSettings, items: packages).description.data(using: .utf8)
        if !FileManager.default.createFile(atPath: filePath, contents: content) {
            throw CustomError.badPackageSwiftFile(path: filePath)
        }

    }
}
