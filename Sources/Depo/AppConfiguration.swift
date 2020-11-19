//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

enum AppConfiguration {

    enum Name {
        static let config: String = "Depofile"
        static let cartfile: String = "Cartfile"
        static let podfile: String = "Podfile"
        static let packageSwift: String = "Package.swift"
        static let podsDirectory: String = "Pods"
    }

    enum Path {
        enum Relative {
            static let podsOutputDirectory: String = "Pods/Build/iOS"
            static let packageSwiftDirectory: String = ".build/checkouts"
            static let packageSwiftBuildsDirectory: String = ".build/builds"
            static let packageSwiftOutputDirectory: String = "SPM/Build/iOS"
        }

        enum Absolute {
            static let buildPodShellScript: String = "/usr/local/bin/build_pod.sh"
            static let buildSPShellScript: String = "/usr/local/bin/build_swift_package.sh"
            static let mergePackageShellScript: String = "/usr/local/bin/merge_package.sh"
            static let moveBuiltPodShellScript: String = "/usr/local/bin/move_built_pod.sh"
        }
    }

    static let podsInternalTargetsPrefix: String = "Pods"
}
