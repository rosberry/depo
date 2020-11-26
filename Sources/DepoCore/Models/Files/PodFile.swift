//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

public struct PodFile: CustomStringConvertible {

    public let description: String
    public let pods: [Pod]

    public init(buildSettings: BuildSettings, pods: [Pod]) {
        self.pods = pods
        self.description = Self.makeDescription(platform: (buildSettings.platform ?? Platform.defaultValue).podfileDescription,
                                                platformVersion: buildSettings.deploymentTarget ?? "",
                                                targetName: buildSettings.targetName,
                                                podsSection: pods.reduce("") { result, pod in
                                                    result + "\n    pod '\(pod.name)'\(Self.podVersion(pod))"
                                                })
    }

    private static func makeDescription(platform: String, platformVersion: String, targetName: String, podsSection: String) -> String {
        """
        install! 'cocoapods', integrate_targets: false
        platform :\(platform), '\(platformVersion)'

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

private extension Platform {
    var podfileDescription: String {
        switch self {
        case .mac:
            return "macos"
        default:
            return self.rawValue
        }
    }
}
