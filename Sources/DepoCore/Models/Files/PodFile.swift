//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

public struct PodFile: CustomStringConvertible {

    public let description: String

    public init(pods: [Pod], platformVersion: Double) {
        self.description = Self.makeDescription(platformVersion: platformVersion,
                                                targetName: "Depo",
                                                podsSection: pods.reduce("") { result, pod in
                                                    result + "    pod '\(pod.name)'\(Self.podVersion(pod))\n"
                                                })
    }

    private static func makeDescription(platformVersion: Double, targetName: String, podsSection: String) -> String {
        """
        install! 'cocoapods', integrate_targets: false
        platform :ios, '\(platformVersion)'

        target '\(targetName)' do
            use_frameworks!

        \(podsSection)

        end

        """
    }

    private static func podVersion(_ pod: Pod) -> String {
        guard let version = pod.versionConstraint else {
            return ""
        }
        return ", '\(version.operation.symbol) \(version.value)'"
    }
}
