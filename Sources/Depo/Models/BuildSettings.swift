//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

struct BuildSettings: Codable {

    enum Error: LocalizedError {
        case badOutput(io: Shell.IO)
        case badBuildSettings([String: String])
    }

    private struct ShellOutputWrapper: Codable {
        let buildSettings: [String: String]
    }

    let productName: String
    let codesigningFolderPath: URL?

    init(targetName: String, shell: Shell = .init(), decoder: JSONDecoder = .init()) throws {
        let io: Shell.IO = try shell("xcodebuild", "-showBuildSettings", "-json", "-target", targetName)
        guard let data = io.stdOut.data(using: .utf8) else {
            throw Error.badOutput(io: io)
        }
        let buildSettings = (try decoder.decode([ShellOutputWrapper].self, from: data)).first?.buildSettings ?? [:]
        try self.init(settings: buildSettings)
    }

    init(settings: [String: String]) throws {
        guard let productName = settings["PRODUCT_NAME"] else {
            throw Error.badBuildSettings(settings)
        }
        self.productName = productName
        self.wrapperName = wrapperName
        self.codesigningFolderPath = URL(string: settings["CODESIGNING_FOLDER_PATH", default: ""])
    }
}
