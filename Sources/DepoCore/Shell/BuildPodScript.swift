//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

public final class BuildPodScript: XcodeBuild {

    @discardableResult
    public func callAsFunction(pod: Pod) throws -> [Shell.IO] {
        [try self(.device(target: pod.name)),
         try self(.simulator(target: pod.name))]
    }
}
