//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import Files

public class XcodeBuild: ShellCommand, ArgumentedShellCommand {

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

    public enum Configuration: String {
        case release = "Release"
        case debug = "Debug"
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

    public func buildForDistribution(_ settings: Settings) throws -> Shell.IO {
        let xcconfig = try xcConfigForDistributionBuild()
        let command = exportCommand(xcconfig: xcconfig)
                      + " && "
                      + (commands + settings.stringArguments(keys: Self.keys)).joined(separator: " ")
        return try shell(command)
    }

    public func create(xcFrameworkAt path: String, fromFrameworksAtPaths frameworkPaths: [String]) throws -> Shell.IO {
        let frameworksArguments = frameworkPaths.reduce([]) { result, path in
            result + ["-framework", path]
        }
        return try shell(commands + ["-create-xcframework"] + ["-output", path] + frameworksArguments)
    }

    private func xcConfigForDistributionBuild() throws -> File {
        let name = "\(UUID().uuidString).xcconfig"
        let content = "BUILD_LIBRARY_FOR_DISTRIBUTION=YES".data(using: .utf8) ?? Data()
        return try Folder.temporary.createFile(named: name, contents: content)
    }

    private func exportCommand(xcconfig: File) -> String {
        "export XCODE_XCCONFIG_FILE=\(xcconfig.path)"
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