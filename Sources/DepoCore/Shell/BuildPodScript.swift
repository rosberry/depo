//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

public final class BuildPodScript: XcodeBuild {

    @discardableResult
    public func callAsFunction(pod: Pod) throws -> [Shell.IO] {
        [try archive(.device(target: pod.name)),
         try archive(.simulator(target: pod.name))]
    }
}
