//
//  Copyright © 2021 Rosberry. All rights reserved.
//

import Foundation
import DepoCore

public protocol HasDepofileExtension {
    var depofileExtension: DataCoder.Kind { get }
    var cacheBuilds: Bool { get }
}

public protocol HasOptionsInit {
    associatedtype Options: HasDepofileExtension

    init(depofile: Depofile, options: Options)
}
