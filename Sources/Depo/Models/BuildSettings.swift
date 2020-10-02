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
    let swiftVersion: String
    let targetName: String
    let codesigningFolderPath: URL?

    init(targetName: String?, shell: Shell = .init(), decoder: JSONDecoder = .init()) throws {
        let command = ["xcodebuild", "-showBuildSettings", "-json"] + (targetName.map { target in
            ["-target", target]
        } ?? [])
        let io: Shell.IO = try shell(command)
        guard let data = io.stdOut.data(using: .utf8) else {
            throw Error.badOutput(io: io)
        }
        let buildSettings = (try decoder.decode([ShellOutputWrapper].self, from: data)).first?.buildSettings ?? [:]
        try self.init(settings: buildSettings)
    }

    init(settings: [String: String]) throws {
        guard let productName = settings["PRODUCT_NAME"],
              let swiftVersion = settings["SWIFT_VERSION"],
              let targetName = settings["TARGETNAME"] else {
            throw Error.badBuildSettings(settings)
        }
        self.productName = productName
        self.swiftVersion = swiftVersion
        self.targetName = targetName
        self.codesigningFolderPath = URL(string: settings["CODESIGNING_FOLDER_PATH", default: ""])
    }
}
