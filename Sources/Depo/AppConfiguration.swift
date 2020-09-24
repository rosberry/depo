//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

enum AppConfiguration {
    static let configFileName: String = "Depofile"
    static let cartFileName: String = "Cartfile"
    static let podFileName: String = "Podfile"
    static let podsInternalTargetsPrefix: String = "Pods"
    static let podsDirectoryName: String = "Pods"
    static let buildPodShellScriptFilePath: String = "/usr/local/bin/build_pod.sh"
    static let mergePodShellScriptFilePath: String = "/usr/local/bin/merge_pod.sh"
    static let moveBuiltPodShellFilePath: String = "/usr/local/bin/move_built_pod.sh"
}
