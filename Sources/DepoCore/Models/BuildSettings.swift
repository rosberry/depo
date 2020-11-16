//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

public struct BuildSettings: Codable {

    public enum Error: LocalizedError {
        case badOutput(io: Shell.IO)
        case badBuildSettings([String: String])
    }

    private struct ShellOutputWrapper: Codable {
        let buildSettings: [String: String]
    }

    public let productName: String
    public let swiftVersion: String
    public let targetName: String
    public let codesigningFolderPath: URL?

    public init(targetName: String? = nil, shell: Shell = .init(), decoder: JSONDecoder = .init()) throws {
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

    public init(settings: [String: String]) throws {
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
