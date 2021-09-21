//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import ArgumentParser
import DepoCore

protocol Update: ParsableCommand {
    associatedtype Manager: PackageManager, HasOptionsInit, ProgressObservable where Manager.Package: GitIdentifiablePackage
    var options: Manager.Options { get }
}

extension Update {
    func run() throws {
        let depofile = try Depofile(decoder: options.depofileExtension.coder)
        let wrapper = PackageManagerWrapper()
        let packages: [Manager.Package] = depofile[keyPath: Manager.keyPath]
        let manager = try wrapper.wrap(packages: packages,
                                       cacheBuilds: options.cacheBuilds,
                                       cacheURL: depofile.cacheURL) { _ in
            Manager(depofile: depofile, options: options).subscribe { state in
                print(state)
            }
        }
        let result = try manager.update()
        try throwIfNotNil(FailedPackagesError(buildResult: result))
    }
}

struct FailedPackagesError<Package>: LocalizedError {
    private let errors: [Error]
    
    var errorDescription: String? {
        errors.map { "\($0)" }.newLineJoined
    }

    init?(buildResult: PackagesOutput<Package>) {
        let errors = buildResult.compactMap { result -> Error? in
            switch result {
            case .success:
                return nil
            case let .failure(error):
                return error
            }
        }
        if errors.isEmpty {
            return nil
        }
        else {
            self.errors = errors
        }
    }
}

func throwIfNotNil(_ error: Error?) throws {
    if let error = error {
        throw error
    }
}
