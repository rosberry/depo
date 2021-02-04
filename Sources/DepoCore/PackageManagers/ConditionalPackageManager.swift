//
// Copyright © 2020 Rosberry. All rights reserved.
//

@propertyWrapper
struct ConditionalPackageManager<PackageManager: CanOutputPackages, Root>: CanOutputPackages {

    public enum Error: Swift.Error {
        case noPackages
    }

    typealias Package = PackageManager.Package
    typealias BuildResult = PackageOutput<Package>

    let outputPath: String = ""

    let wrappedValue: PackageManager
    let keyPath: KeyPath<Root, Bool>

    private func doIfPossible<T>(root: Root, action: () throws -> T) throws -> T {
        guard root[keyPath: keyPath] else {
            throw Error.noPackages
        }
        return try action()
    }
}

extension ConditionalPackageManager: HasUpdateCommand where PackageManager: HasUpdateCommand, Root == [Package] {
    func update(packages: [Package]) throws -> [BuildResult] {
        try doIfPossible(root: packages) {
            try wrappedValue.update(packages: packages)
        }
    }
}

extension ConditionalPackageManager: HasBuildCommand where PackageManager: HasBuildCommand, Root == [Package] {
    func build(packages: [Package]) throws -> [BuildResult] {
        try doIfPossible(root: packages) {
            try wrappedValue.build(packages: packages)
        }
    }
}

extension ConditionalPackageManager: HasInstallCommand where PackageManager: HasInstallCommand, Root == [Package] {
    func install(packages: [Package]) throws -> [BuildResult] {
        try doIfPossible(root: packages) {
            try wrappedValue.install(packages: packages)
        }
    }
}
