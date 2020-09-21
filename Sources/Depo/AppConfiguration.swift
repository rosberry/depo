//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

enum AppConfiguration {
    static let configFileName: String = "CarPodfile"
    static let cartFileName: String = "Cartfile"
    static let podFileName: String = "Podfile"
    static let podsDirectoryName: String = "Pods"
    static let buildFrameworkShellScriptFilePath: String = "/usr/local/bin/build_framework.sh"
    static let mergePodShellScriptFilePath: String = "/usr/local/bin/merge_pod.sh"
    static let moveBuiltPodShellFilePath: String = "/usr/local/bin/move_built_pod.sh"
}
