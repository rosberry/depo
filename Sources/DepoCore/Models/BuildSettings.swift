//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

#warning("public init(settings:) should be replaced by Codable")

public struct BuildSettings {

    public enum Error: Swift.Error {
        case badOutput(io: Shell.IO)
        case badBuildSettings(missedKey: String, settings: [String: String])
    }

    private struct ShellOutputWrapper: Codable {
        let buildSettings: [String: String]
    }

    public let productName: String
    public let swiftVersion: String
    public let targetName: String
    public let codesigningFolderPath: URL?
    public let platform: Platform?
    public let deploymentTarget: String?
    public let developmentTeam: String

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
        let extract = BuildSettings.extract
        let productName     = try extract("PRODUCT_NAME", settings)
        let swiftVersion    = try extract("SWIFT_VERSION", settings)
        let targetName      = try extract("TARGETNAME", settings)
        let developmentTeam = try extract("DEVELOPMENT_TEAM", settings)
        self.productName = productName
        self.swiftVersion = swiftVersion
        self.targetName = targetName
        self.codesigningFolderPath = URL(string: settings["CODESIGNING_FOLDER_PATH", default: ""])
        self.developmentTeam = developmentTeam
        if let platform = Self.platform(from: settings) {
            self.platform = platform
            self.deploymentTarget = settings[Self.deploymentTargetKey(platform: platform)]
        }
        else {
            self.platform = nil
            self.deploymentTarget = nil
        }
    }

    public init(productName: String,
                swiftVersion: String,
                targetName: String,
                codesigningFolderPath: URL?,
                platform: Platform?,
                deploymentTarget: String?,
                developmentTeam: String) {
        self.productName = productName
        self.swiftVersion = swiftVersion
        self.targetName = targetName
        self.codesigningFolderPath = codesigningFolderPath
        self.platform = platform
        self.deploymentTarget = deploymentTarget
        self.developmentTeam = developmentTeam
    }

    private static func platform(from settings: [String: String]) -> Platform? {
        Platform.allCases.first { platform in
            settings[deploymentTargetKey(platform: platform)] != nil
        }
    }

    private static func deploymentTargetKey(platform: Platform) -> String {
        let prefix: String
        switch platform {
        case .mac:
            prefix = "MACOSX_"
        case .ios:
            prefix = "IPHONEOS_"
        case .tvos:
            prefix = "TVOS_"
        case .watchos:
            prefix = "WATCHOS_"
        case .all:
            prefix = ""
        }
        return "\(prefix)DEPLOYMENT_TARGET"
    }

    private static func extract(key: String, from settings: [String: String]) throws -> String {
        guard let value = settings[key] else {
            throw Error.badBuildSettings(missedKey: key, settings: settings)
        }
        return value
    }
}
