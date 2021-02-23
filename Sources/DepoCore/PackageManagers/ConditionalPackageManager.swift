//
// Copyright © 2020 Rosberry. All rights reserved.
//

struct ConditionalPackageManager<PM: PackageManager>: PackageManager {

    public enum Error: Swift.Error {
        case noPackages
    }

    typealias Package = PM.Package
    typealias BuildResult = PackageOutput<Package>

    static var outputPath: String {
        PM.outputPath
    }
    let packages: [Package]
    let packageManagerFactory: ([PM.Package]) -> PM
    let keyPath: KeyPath<[Package], Bool>

    private var wrappedValue: PM {
        packageManagerFactory(packages)
    }

    private func doIfNeeded<T>(action: () throws -> T) throws -> T {
        guard packages[keyPath: keyPath] else {
            throw Error.noPackages
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

