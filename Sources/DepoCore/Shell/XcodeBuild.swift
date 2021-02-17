//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import Files

public class XcodeBuild: ShellCommand, ArgumentedShellCommand {

    typealias Output = (File?, Int32)

    public struct Settings: ShellCommandArguments {
        let target: String?
        let scheme: String?
        let configuration: Configuration
        let isDefineModules: Bool
        let sdk: SDK
        let arch: Arch?
        let isOnlyActiveArch: Bool?
        let isQuiet: Bool
        let derivedDataPath: String?
        let actionType: ActionType?
    }

    public enum Configuration: String, CustomStringConvertible {
        case release = "Release"
        case debug = "Debug"

        public var description: String {
            self.rawValue
        }
    }

    public enum SDK: String {
        case iphoneos
        case iphonesimulator
    }

    public enum Arch: String {
        //swiftlint:disable:next identifier_name
        case x86_64
    }

    public enum ActionType: String {
        case build
        case archive
    }

    public enum Error: Swift.Error {
        case badOutput(shellOutput: String)
    }

    public struct Version {
        let xcodeVersion: String
        let buildVersion: String
    }

    public static let keys: [AnyArgument<Settings>] =
            [.init(optionalKeyPath: \.target, "-target "),
             .init(optionalKeyPath: \.scheme, "-scheme "),
             .init(\.configuration, "-configuration "),
             .init(\.isDefineModules, "defines_module=", { $0.yesOrNo }),
             .init(\.sdk, "-sdk "),
             .init(optionalKeyPath: \.arch, "-arch "),
             .init(optionalKeyPath: \.isOnlyActiveArch, "only-active-arch=", { $0.yesOrNo }),
             .init(\.isQuiet, "-quiet", { _ in "" }),
             .init(optionalKeyPath: \.derivedDataPath, "-derivedDataPath "),
             .init(optionalKeyPath: \.actionType, "")]

    public override init(commandPath: String = AppConfiguration.Path.Absolute.xcodebuild, shell: Shell) {
        super.init(commandPath: commandPath, shell: shell)
    }

    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }

    public static func version(shell: Shell) throws -> Version {
        let output = try shell(silent: "xcodebuild -version")
        guard let xcodeVersionStartIndex = output.range(of: #"Xcode "#, options: .regularExpression)?.upperBound,
              let buildVersionStartIndex = output.range(of: #"Build version "#, options: .regularExpression)?.upperBound,
              let xcodeVersionLineLastIndex = output[from: xcodeVersionStartIndex].firstIndex(of: "\n"),
              let buildVersionLineLastIndex = output[from: buildVersionStartIndex].firstIndex(of: "\n") else {
            throw Error.badOutput(shellOutput: output)
        }
        let xcodeVersion = String(output[xcodeVersionStartIndex..<xcodeVersionLineLastIndex])
        let buildVersion = String(output[buildVersionStartIndex..<buildVersionLineLastIndex])
        return .init(xcodeVersion: xcodeVersion, buildVersion: buildVersion)
    }

    public func buildForDistribution(settings: Settings) throws -> String {
        let xcconfig = try xcConfigForDistributionBuild()
        let command = exportCommand(xcconfig: xcconfig)
                      + " && "
                      + "\(self.command) \(settings.stringArguments(keys: Self.keys).spaceJoined)"
        return try shell(silent: command)
    }

    public func create(xcFrameworkAt path: String, fromFrameworksAtPaths frameworkPaths: [String]) throws -> String {
        let frameworksArguments = frameworkPaths.reduce("") { result, path in
            result + "-framework \(path) "
        }
        return try shell(silent: "\(command) -create-xcframework -output \(path) \(frameworksArguments)")
    }

    public func showBuildSettings() throws -> String {
        try shell(silent: Self.showBuildSettingsCommand())
    }

    public func showBuildSettings(target: String) throws -> String {
        try shell(silent: Self.showBuildSettingsCommand(target: target))
    }

    public func showBuildSettings(scheme: String) throws -> String {
        try shell(silent: Self.showBuildSettingsCommand(scheme: scheme))
    }

    public func schemes(decoder: JSONDecoder = .init()) throws -> [String] {
        let output = try shell(silent: "xcodebuild -list -json")
        return try schemes(fromOutput: output)
    }

    public func listProject(name: String? = nil, decoder: JSONDecoder = .init()) throws -> XcodeList.Project {
        struct OutputWrapper: Codable {
            let project: XcodeList.Project
        }

        let output: String
        if let name = name {
            output = try shell(silent: "xcodebuild -list -json -project \(name)")
        }
        else {
            output = try shell(silent: "xcodebuild -list -json")
        }
        guard let data = output.data(using: .utf8) else {
            throw Error.badOutput(shellOutput: output)
        }
        return try decoder.decode(OutputWrapper.self, from: data).project
    }

    public func listWorkspace(name: String? = nil, decoder: JSONDecoder = .init()) throws -> XcodeList.Workspace {
        struct OutputWrapper: Codable {
            let workspace: XcodeList.Workspace
        }

        let output: String
        if let name = name {
            output = try shell(silent: "xcodebuild -list -json -workspace \(name)")
        }
        else {
            output = try shell(silent: "xcodebuild -list -json")
        }
        guard let data = output.data(using: .utf8) else {
            throw Error.badOutput(shellOutput: output)
        }
        return try decoder.decode(OutputWrapper.self, from: data).workspace
    }

    public func version() throws -> Version {
        try Self.version(shell: shell)
    }

    private func xcConfigForDistributionBuild() throws -> File {
        let name = "\(UUID().uuidString).xcconfig"
        let content = "BUILD_LIBRARY_FOR_DISTRIBUTION=YES".data(using: .utf8) ?? Data()
        return try Folder.temporary.createFile(named: name, contents: content)
    }

    private func exportCommand(xcconfig: File) -> String {
        "export XCODE_XCCONFIG_FILE=\(xcconfig.path)"
    }

    private static func showBuildSettingsCommand() -> String {
        "xcodebuild -showBuildSettings -json"
    }

    private static func showBuildSettingsCommand(target: String) -> String {
        "xcodebuild -showBuildSettings -json -target \(target)"
    }

    private static func showBuildSettingsCommand(scheme: String) -> String {
        "xcodebuild -showBuildSettings -json -scheme \(scheme)"
    }

    private func schemes(fromOutput: String) throws -> [String] {
        guard let data = fromOutput.data(using: .utf8),
              let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let entry = (json["project"] ?? json["workspace"]) as? [String: Any],
              let schemes = entry["schemes"] as? [String] else {
            return []
        }
        return schemes
    }
}

extension XcodeBuild.Settings {

    static func simulator(target: String, configuration: XcodeBuild.Configuration = .release) -> Self {
        XcodeBuild.Settings(target: target,
                            scheme: nil,
                            configuration: configuration,
                            isDefineModules: true,
                            sdk: .iphonesimulator,
                            arch: .x86_64,
                            isOnlyActiveArch: false,
                            isQuiet: true,
                            derivedDataPath: nil,
                            actionType: .archive)
    }

    static func device(target: String, configuration: XcodeBuild.Configuration = .release) -> Self {
        XcodeBuild.Settings(target: target,
                            scheme: nil,
                            configuration: configuration,
                            isDefineModules: true,
                            sdk: .iphoneos,
                            arch: nil,
                            isOnlyActiveArch: nil,
                            isQuiet: true,
                            derivedDataPath: nil,
                            actionType: .archive)
    }

    static func simulator(scheme: String,
                          configuration: XcodeBuild.Configuration = .release,
                          derivedDataPath: String? = nil,
                          actionType: XcodeBuild.ActionType? = nil) -> Self {
        XcodeBuild.Settings(target: nil,
                            scheme: scheme,
                            configuration: configuration,
                            isDefineModules: true,
                            sdk: .iphonesimulator,
                            arch: .x86_64,
                            isOnlyActiveArch: false,
                            isQuiet: true,
                            derivedDataPath: derivedDataPath,
                            actionType: actionType)
    }

    static func device(scheme: String,
                       configuration: XcodeBuild.Configuration = .release,
                       derivedDataPath: String? = nil,
                       actionType: XcodeBuild.ActionType? = nil) -> Self {
        XcodeBuild.Settings(target: nil,
                            scheme: scheme,
                            configuration: configuration,
                            isDefineModules: true,
                            sdk: .iphoneos,
                            arch: nil,
                            isOnlyActiveArch: nil,
                            isQuiet: true,
                            derivedDataPath: derivedDataPath,
                            actionType: actionType)
    }
}

fileprivate extension Bool {
    var yesOrNo: String {
        switch self {
        case true:
            return "yes"
        case false:
            return "no"
        }
    }
}
