//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

enum AppConfiguration {
    static let configFileName: String = "CarPodfile"
    static let cartFileName: String = "Cartfile"
    static let podFileName: String = "Podfile"
    static let packageSwiftFileName: String = "Package.swift"
    static let podsDirectoryName: String = "Pods"
    static let packageSwiftDirectoryName: String = ".build/checkouts"
    static let buildPodShellScriptFilePath: String = "/usr/local/bin/build_pod.sh"
    static let buildSPShellScriptFilePath: String = "/usr/local/bin/build_swift_package.sh"
    static let mergePodShellScriptFilePath: String = "/usr/local/bin/merge_pod.sh"
    static let moveBuiltPodShellFilePath: String = "/usr/local/bin/move_built_pod.sh"
}
