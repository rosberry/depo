//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

struct PodFile: CustomStringConvertible {

    let description: String

    init(pods: [Pod], platformVersion: Double) {
        let podsSection = pods.map { pod in
            "    pod '\(pod.name)'\(Self.podVersion(pod))"
        }.joined(separator: "\n")
        self.description = """
                           install! 'cocoapods', integrate_targets: false
                           platform :ios, '\(platformVersion)'

                           target 'Depo' do
                               use_frameworks!

                           \(podsSection)

                           end

                           """
    }

    private static func podVersion(_ pod: Pod) -> String {
        pod.version.map { version in
            ", '\(version.operation.symbol) \(version.value)'"
        } ?? ""
    }
}
