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

    private enum Action {
        case generateEmpty
        case generateBy([File])
    }

    @OptionGroup()
    var options: Options
    private let packageManagersFileNames: [String] = [AppConfiguration.cartFileName,
                                                      AppConfiguration.podFileName,
                                                      AppConfiguration.packageSwiftFileName]

    func run() throws {
        print(try action(for: options))
    }

    private func action(for options: Options) throws -> Action {
        guard !options.filePaths.isEmpty else {
            return .generateEmpty
        }
        let files = try options.filePaths.compactMap { path -> File? in
            guard let url = URL(string: path),
                  packageManagersFileNames.contains(url.lastPathComponent) else {
                return nil
            }
            return try Folder.current.file(at: path)
        }
        return .generateBy(files)
    }
}
