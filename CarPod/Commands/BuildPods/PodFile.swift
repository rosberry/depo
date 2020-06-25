//
// Copyright (c) 2020 ___FULLUSERNAME___. All rights reserved.
//

import Foundation

struct PodFile: CustomStringConvertible {

    let description: String

    init(pods: [Pod], platformVersion: Double) {
        let podsSection = pods.map { pod in
            "    pod '\(pod.name)'"
        }.joined(separator: "\n")
        self.description = """
                           install! 'cocoapods', integrate_targets: false
                           platform :ios, '\(platformVersion)'

                           target 'CarPod' do
                               use_frameworks!

                           \(podsSection)

                           end

                           """
    }
}
