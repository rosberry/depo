//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import ArgumentParser
import DepoCore

protocol Build: ParsableCommand, HasDepofileKeyPath {
    associatedtype Manager: HasBuildCommand, HasOptionsInit, ProgressObservable
    var options: Manager.Options { get }
}

extension Build where ValueType == [Manager.Package] {
    func run() throws {
        let depofile = try Depofile(decoder: options.depofileExtension.coder)
        let manager = Manager(options: options).subscribe { state in
            print(state)
        }
        try manager.build(packages: depofile[keyPath: Self.depofileKeyPath])
    }
}
