//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

public enum AppConfiguration {
    public static let configFileName: String = "Depofile"
    public static let cartFileName: String = "Cartfile"
    public static let podFileName: String = "Podfile"
    public static let packageSwiftFileName: String = "Package.swift"
    public static let podsOutputDirectoryName: String = "Pods/Build/iOS"
    public static let podsInternalTargetsPrefix: String = "Pods"
    public static let podsDirectoryName: String = "Pods"
    public static let packageSwiftDirectoryName: String = ".build/checkouts"
    public static let packageSwiftBuildsDirectoryName: String = ".build/builds"
    public static let packageSwiftOutputDirectoryName: String = "SPM/Build/iOS"
    public static let buildPodShellScriptFilePath: String = "/usr/local/bin/build_pod.sh"
    public static let buildSPShellScriptFilePath: String = "/usr/local/bin/build_swift_package.sh"
    public static let mergePackageShellScriptFilePath: String = "/usr/local/bin/merge_package.sh"
    public static let moveBuiltPodShellFilePath: String = "/usr/local/bin/move_built_pod.sh"
}
