//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

public enum AppConfiguration {

    public enum Name {
        public static let config: String = "Depofile"
        public static let cartfile: String = "Cartfile"
        public static let podfile: String = "Podfile"
        public static let packageSwift: String = "Package.swift"
        public static let podsDirectory: String = "Pods"
    }

    public enum Path {
        public enum Relative {
            public static let podsOutputDirectory: String = "Pods/Build/iOS"
            public static let packageSwiftDirectory: String = ".build/checkouts"
            public static let packageSwiftBuildsDirectory: String = ".build/builds"
            public static let packageSwiftOutputDirectory: String = "SPM/Build/iOS"
            public static let carthageBuildDirectory: String = "Carthage/Build"
            public static let carthageIosBuildDirectory: String = "Carthage/Build/iOS"
        }

        public enum Absolute {
            public static let buildSPShellScript: String = "/usr/local/bin/build_swift_package.sh"
            public static let podCommandPath: String = "pod"
            public static let carthageCommandPath: String = "carthage"
            public static let swiftCommandPath: String = "swift"
            public static let xcodebuild: String = "xcodebuild"
            public static let lipo: String = "lipo"
        }
    }

    public static let podsInternalTargetsPrefix: String = "Pods"
    public static let xcodeProjectExtension: String = "xcodeproj"
}
