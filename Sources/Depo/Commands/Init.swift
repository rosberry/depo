//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import ArgumentParser
import Files
import DepoCore

final class Init: ParsableCommand {

    struct Options: ParsableArguments {

        @Argument()
        var filePaths: [String] = []
    }

    fileprivate enum Action {

        struct Paths {

            typealias FieldContext = (keyPath: WritableKeyPath<Self, String?>, value: String)

            var cartfilePath: String?
            var podfilePath: String?
            var packageSwiftFilePath: String?

            static let fileNames: [FieldContext] = {
                [(\.cartfilePath, AppConfiguration.cartFileName),
                 (\.podfilePath, AppConfiguration.podFileName),
                 (\.packageSwiftFilePath, AppConfiguration.packageSwiftFileName)]
            }()
        }

        case generateEmpty
        case generateBy(Paths)
    }

    fileprivate struct Files {
        let cartfile: Cartfile?
        let podfilePath: PodFile?
        let packageSwiftFilePath: PackageSwift?
    }

    @OptionGroup()
    var options: Options

    private let shell: Shell = .init()
    private let pod: PodShellCommand = .init()
    private let swiftPackage: SwiftPackageShellCommand = .init()
    private let carthage: CarthageShellCommand = .init()

    func run() throws {
        switch try action(for: options) {
        case .generateEmpty:
            generateEmptyDepofile()
        case let .generateBy(files):
            try generateDepofile(by: files)
        }
    }

    private func action(for options: Options) throws -> Action {
        guard let files = self.paths(from: options.filePaths) else {
            return .generateEmpty
        }
        return .generateBy(files)
    }

    private func generateEmptyDepofile() {
        print(#function)
    }

    private func generateDepofile(by files: Action.Paths) throws {
        // let buildSettings = try BuildSettings()
        // let podfile = try pod.podfile(buildSettings: .init(), path: files.podfilePath!)
        /*guard let packageSwift = try swiftPackage.packageSwift(buildSettings: buildSettings, path: files.packageSwiftFilePath!) else {
            return
        }*/
        guard let cartfile = try carthage.cartfile(path: files.cartfilePath!) else {
            return
        }
        print(cartfile)
    }

    private func paths(from paths: [String]) -> Action.Paths? {
        guard !paths.isEmpty else {
            return nil
        }
        let paths: [Init.Action.Paths.FieldContext] = options.filePaths.compactMap { path in
            guard let url = URL(string: path),
                  let keyPath = Action.Paths.fileNames.first(with: url.lastPathComponent, at: \.value)?.keyPath else {
                return nil
            }
            return (keyPath, path)
        }
        return Action.Paths(fields: paths)
    }

    private func files(from paths: Action.Paths) -> Files {
        .init(cartfile: nil, podfilePath: nil, packageSwiftFilePath: nil)
    }
}

fileprivate extension Init.Action.Paths {
    init(fields: [FieldContext]) {
        var this = Self()
        fields.forEach { (keyPath, value) in
            this[keyPath: keyPath] = value
        }
        self = this
    }
}
