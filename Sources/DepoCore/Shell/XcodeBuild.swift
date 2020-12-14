//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

public class XcodeBuild: ShellCommand {

    public struct Settings {
        let target: String
        let configuration: Configuration
        let isDefineModules: Bool
        let sdk: SDK
        let arch: Arch?
        let isOnlyActiveArch: Bool?
        let isQuiet: Bool
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

    public override init(commandPath: String = AppConfiguration.Path.Absolute.xcodebuild, shell: Shell) {
        super.init(commandPath: commandPath, shell: shell)
    }

    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }

    public func archive(_ settings: Settings) throws -> Shell.IO {
        try shell([commandPath] + settings.stringArguments + ["archive"])
    }
}

extension XcodeBuild.Settings {

    struct AnyArgument<Root> {

        let value: (Root) -> [String]

        init<T>(optionalKeyPath: KeyPath<Root, T?>, _ key: String, _ map: @escaping (T) -> String = { "\($0)" }) {
            value = { root in
                root[keyPath: optionalKeyPath].map { value in
                    (key + map(value)).split(separator: " ").map { substring in
                        String(substring)
                    }
                } ?? []
            }
        }

        init<T>(_ keyPath: KeyPath<Root, T>, _ key: String, _ map: @escaping (T) -> String = { "\($0)" }) {
            value = { root -> [String] in
                (key + map(root[keyPath: keyPath])).split(separator: " ").map { substring in
                    String(substring)
                }
            }
        }
    }

    static func simulator(target: String, configuration: XcodeBuild.Configuration = .release) -> Self {
        XcodeBuild.Settings(target: target,
                            configuration: configuration,
                            isDefineModules: true,
                            sdk: .iphonesimulator,
                            arch: .x86_64,
                            isOnlyActiveArch: false,
                            isQuiet: true)
    }

    static func device(target: String, configuration: XcodeBuild.Configuration = .release) -> Self {
        XcodeBuild.Settings(target: target,
                            configuration: configuration,
                            isDefineModules: true,
                            sdk: .iphoneos,
                            arch: nil,
                            isOnlyActiveArch: nil,
                            isQuiet: true)
    }

    var stringArguments: [String] {
        Self.keys.reduce([]) { acc, argument in
            acc + argument.value(self)
        }
    }

    static var keys: [AnyArgument<Self>] {
        [.init(\Self.target, "-target "),
         .init(\Self.configuration, "-configuration "),
         .init(\Self.isDefineModules, "defines_module=", { $0.yesOrNo }),
         .init(\Self.sdk, "-sdk "),
         .init(optionalKeyPath: \Self.arch, "-arch "),
         .init(optionalKeyPath: \Self.isOnlyActiveArch, "only-active-arch=", { $0.yesOrNo }),
         .init(\Self.isQuiet, "-quiet", { _ in "" })]
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
