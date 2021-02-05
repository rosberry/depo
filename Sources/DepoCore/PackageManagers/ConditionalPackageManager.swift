//
// Copyright © 2020 Rosberry. All rights reserved.
//

@propertyWrapper
struct ConditionalPackageManager<PackageManager: CanOutputPackages>: CanOutputPackages {

    public enum Error: Swift.Error {
        case noPackages
    }

    typealias Package = PackageManager.Package
    typealias BuildResult = PackageOutput<Package>

    let outputPath: String = ""

    let wrappedValue: PackageManager
    let keyPath: KeyPath<[Package], Bool>

    private func doIfPossible<T>(packages: [Package], action: () throws -> T) throws -> T {
        guard packages[keyPath: keyPath] else {
            throw Error.noPackages
        }
        return try action()
    }
}

extension ConditionalPackageManager: HasUpdateCommand where PackageManager: HasUpdateCommand {
    func update(packages: [Package]) throws -> [BuildResult] {
        try doIfPossible(packages: packages) {
            try wrappedValue.update(packages: packages)
        }
    }
}

extension ConditionalPackageManager: HasBuildCommand where PackageManager: HasBuildCommand {
    func build(packages: [Package]) throws -> [BuildResult] {
        try doIfPossible(packages: packages) {
            try wrappedValue.build(packages: packages)
        }
    }
}

extension ConditionalPackageManager: HasInstallCommand where PackageManager: HasInstallCommand {
    func install(packages: [Package]) throws -> [BuildResult] {
        try doIfPossible(packages: packages) {
            try wrappedValue.install(packages: packages)
        }
    }
}
