//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

public class XcodeBuild: ShellCommand, ArgumentedShellCommand {

    public struct Settings: ShellCommandArguments {
        let target: String
        let configuration: Configuration
        let isDefineModules: Bool
        let sdk: SDK
        let arch: Arch?
        let isOnlyActiveArch: Bool?
        let isQuiet: Bool
        let actionType: ActionType
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
        case x86_64
    }

    public enum ActionType: String {
        case build
        case archive
    }

    static var keys: [AnyArgument<Settings>] {
        [.init(\.target, "-target "),
         .init(\.configuration, "-configuration "),
         .init(\.isDefineModules, "defines_module=", { $0.yesOrNo }),
         .init(\.sdk, "-sdk "),
         .init(optionalKeyPath: \.arch, "-arch "),
         .init(optionalKeyPath: \.isOnlyActiveArch, "only-active-arch=", { $0.yesOrNo }),
         .init(\.isQuiet, "-quiet", { _ in "" }),
         .init(\.actionType, "")]
    }

    public override init(commandPath: String = AppConfiguration.Path.Absolute.xcodebuild, shell: Shell) {
        super.init(commandPath: commandPath, shell: shell)
    }

    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
}

extension XcodeBuild.Settings {

    static func simulator(target: String, configuration: XcodeBuild.Configuration = .release) -> Self {
        XcodeBuild.Settings(target: target,
                            configuration: configuration,
                            isDefineModules: true,
                            sdk: .iphonesimulator,
                            arch: .x86_64,
                            isOnlyActiveArch: false,
                            isQuiet: true,
                            actionType: .archive)
    }

    static func device(target: String, configuration: XcodeBuild.Configuration = .release) -> Self {
        XcodeBuild.Settings(target: target,
                            configuration: configuration,
                            isDefineModules: true,
                            sdk: .iphoneos,
                            arch: nil,
                            isOnlyActiveArch: nil,
                            isQuiet: true,
                            actionType: .archive)
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
