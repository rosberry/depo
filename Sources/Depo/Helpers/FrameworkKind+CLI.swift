//
// Copyright © 2020 Rosberry. All rights reserved.
//

import DepoCore
import ArgumentParser

extension MergePackage.FrameworkKind: EnumerableFlag {
    public static func name(for value: Self) -> NameSpecification {
        switch value {
        case .fatFramework:
            return .customLong("fat-framework")
        case .xcframework:
            return .customLong("xcframework")
        }
    }
}
