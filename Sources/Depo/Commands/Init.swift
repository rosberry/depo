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

        struct Files {

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
        case generateBy(Files)
    }

    @OptionGroup()
    var options: Options

    func run() throws {
        switch try action(for: options) {
        case .generateEmpty:
            generateEmptyDepofile()
        case let .generateBy(files):
            generateDepofile(by: files)
        }
    }

    private func action(for options: Options) throws -> Action {
        guard let files = self.files(from: options.filePaths) else {
            return .generateEmpty
        }
        return .generateBy(files)
    }

    private func generateEmptyDepofile() {
        print(#function)
    }

    private func generateDepofile(by files: Action.Files) {
        print(#function, files)
    }

    private func files(from paths: [String]) -> Action.Files? {
        guard !paths.isEmpty else {
            return nil
        }
        let paths: [Init.Action.Files.FieldContext] = options.filePaths.compactMap { path in
            guard let url = URL(string: path),
                  let keyPath = Action.Files.fileNames.first(with: url.lastPathComponent, at: \.value)?.keyPath else {
                return nil
            }
            return (keyPath, path)
        }
        return Action.Files(fields: paths)
    }
}

fileprivate extension Init.Action.Files {
    init(fields: [FieldContext]) {
        var this = Self()
        fields.forEach { (keyPath, value) in
            this[keyPath: keyPath] = value
        }
        self = this
    }
}
