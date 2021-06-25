//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import DepoCore

extension StaticLibraryBuilderService.State: CustomStringConvertible {
    public var description: String {
        switch self {
        case let .shell(state):
            return state.description
        case .buildSchemeForEachSDK:
            return string("==> ", color: .cyan) + "Building scheme for each SDK"
        case .makeStaticLibraryPerSDK:
            return string("==> ", color: .cyan) + "Making static library for each SDK"
        case .makeFatStaticLibrary:
            return string("==> ", color: .cyan) + "Making fat static library"
        case .collectingSwiftModules:
            return string("==> ", color: .cyan) + "Collecting swiftmodules"
        }
    }
}
