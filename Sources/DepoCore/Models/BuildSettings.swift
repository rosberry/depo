//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

#warning("public init(settings:) should be replaced by Codable")

public struct BuildSettings {

    public enum Error: Swift.Error {
        case badOutput(shellIO: Shell.IO)
        case badBuildSettings(missedKey: String, shellIO: Shell.IO)
    }

    private enum InternalError: Swift.Error {
        case badExtract(missedKey: String, settings: [String: String])
    }

    private struct RawSettings: Codable {
        let buildSettings: [String: String]
    }

    public let productName: String
    public let swiftProjectVersion: String
    public let targetName: String
    public let productType: ProductType?
    public let codesigningFolderPath: URL?
    public let platform: Platform?
    public let deploymentTarget: String?
    public let supportedPlatforms: Set<Platform>

    public init(xcodebuild: XcodeBuild, decoder: JSONDecoder = .init()) throws {
        let shellIO: Shell.IO = try xcodebuild.showBuildSettings()
        try self.init(shellIO: shellIO, decoder: decoder)
    }

    public init(target: String, xcodebuild: XcodeBuild, decoder: JSONDecoder = .init()) throws {
        let shellIO: Shell.IO = try xcodebuild.showBuildSettings(target: target)
        try self.init(shellIO: shellIO, decoder: decoder)
    }

    public init(scheme: String, xcodebuild: XcodeBuild, decoder: JSONDecoder = .init()) throws {
        let shellIO: Shell.IO = try xcodebuild.showBuildSettings(scheme: scheme)
        try self.init(shellIO: shellIO, decoder: decoder)
    }

    private init(shellIO: Shell.IO, decoder: JSONDecoder) throws {
        guard let data = shellIO.stdOut.data(using: .utf8) else {
            throw Error.badOutput(shellIO: shellIO)
        }
        let buildSettings = (try decoder.decode([RawSettings].self, from: data)).first?.buildSettings ?? [:]
        do {
            try self.init(settings: buildSettings)
        }
        catch let InternalError.badExtract(missedKey, _) {
            throw Error.badBuildSettings(missedKey: missedKey, shellIO: shellIO)
        }
    }

    private init(settings: [String: String]) throws {
        let extract = BuildSettings.extract
        let productName = try extract("PRODUCT_NAME", settings)
        let swiftVersion = try extract("SWIFT_VERSION", settings)
        let targetName = try extract("TARGETNAME", settings)
        let productType = settings["PRODUCT_TYPE", default: ""]
        self.productName = productName
        self.swiftProjectVersion = swiftVersion
        self.targetName = targetName
        self.productType = productType.isEmpty ? nil : ProductType(rawValue: productType)
        self.codesigningFolderPath = URL(string: settings["CODESIGNING_FOLDER_PATH", default: ""])
        if let platform = Self.platform(from: settings) {
            self.platform = platform
            self.deploymentTarget = settings[Self.deploymentTargetKey(platform: platform)]
        }
        else {
            self.platform = nil
            self.deploymentTarget = nil
        }
        self.supportedPlatforms = Self.supportedPlatforms(from: settings)
    }

    public init(productName: String,
                swiftVersion: String,
                targetName: String,
                productType: ProductType,
                codesigningFolderPath: URL?,
                platform: Platform?,
                deploymentTarget: String?,
                supportedPlatforms: Set<Platform>) {
        self.productName = productName
        self.swiftProjectVersion = swiftVersion
        self.targetName = targetName
        self.productType = productType
        self.codesigningFolderPath = codesigningFolderPath
        self.platform = platform
        self.deploymentTarget = deploymentTarget
        self.supportedPlatforms = supportedPlatforms
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
        }
        return "\(prefix)DEPLOYMENT_TARGET"
    }

    private static func supportedPlatforms(from settings: [String: String]) -> Set<Platform> {
        if let supportedPlatforms = settings["SUPPORTED_PLATFORMS"] {
            let platforms = supportedPlatforms.split(separator: " ").compactMap { substring -> Platform? in
                Platform(key: String(substring))
            }
            return Set(platforms)
        }
        else if let platformStringValue = settings["PLATFORM_NAME"],
                let platform = Platform(key: platformStringValue) {
            return Set([platform])
        }
        else {
            return []
        }
    }

    private static func extract(key: String, from settings: [String: String]) throws -> String {
        guard let value = settings[key] else {
            throw InternalError.badExtract(missedKey: key, settings: settings)
        }
        return value
    }
}
