//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

struct ConditionalPackageManager<PM: PackageManager>: PackageManager {

    public enum Error: Swift.Error, LocalizedError {
        case noPackages(String)

        public var errorDescription: String? {
            switch self {
            case let .noPackages(path):
                return "No packages to build for \(path)"
            }
        }
    }

    typealias Package = PM.Package
    typealias BuildResult = PackageOutput<Package>

    static var outputPath: String {
        PM.outputPath
    }
    static var keyPath: KeyPath<Depofile, [PM.Package]> {
        fatalError("ConditionalPackageManager.keyPath is not implemented")
    }
    let packages: [Package]
    let packageManagerFactory: ([PM.Package]) -> PM
    let conditionKeyPath: KeyPath<[Package], Bool>

    private var wrappedValue: PM {
        packageManagerFactory(packages)
    }

    private func doIfNeeded<T>(action: () throws -> T) throws -> T {
        guard packages[keyPath: conditionKeyPath] else {
            throw Error.noPackages(Self.outputPath)
        }
        return try action()
    }

    func update() throws -> PackagesOutput<PM.Package> {
        try doIfNeeded {
            try wrappedValue.update()
        }
    }

    func install() throws -> PackagesOutput<PM.Package> {
        try doIfNeeded {
            try wrappedValue.update()
        }
    }

    func build() throws -> PackagesOutput<PM.Package> {
        try doIfNeeded {
            try wrappedValue.update()
        }
    }
}
