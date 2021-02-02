//
// Copyright © 2020 Rosberry. All rights reserved.
//

@propertyWrapper
struct ConditionalPackageManager<PackageManager: CanOutputPackages, Root>: CanOutputPackages {

    typealias Packages = PackageManager.Packages

    let outputPath: String = ""

    let wrappedValue: PackageManager
    let keyPath: KeyPath<Root, Bool>

    private func doIfPossible(root: Root, action: () throws -> Void) throws {
        guard root[keyPath: keyPath] else {
            return
        }
        try action()
    }
}

extension ConditionalPackageManager: HasUpdateCommand where PackageManager: HasUpdateCommand, Root == PackageManager.Packages {
    func update(packages: PackageManager.Packages) throws {
        try doIfPossible(root: packages) {
            try wrappedValue.update(packages: packages)
        }
    }
}

extension ConditionalPackageManager: HasBuildCommand where PackageManager: HasBuildCommand, Root == PackageManager.Packages {
    func build(packages: PackageManager.Packages) throws {
        try doIfPossible(root: packages) {
            try wrappedValue.build(packages: packages)
        }
    }
}

extension ConditionalPackageManager: HasInstallCommand where PackageManager: HasInstallCommand, Root == PackageManager.Packages {
    func install(packages: PackageManager.Packages) throws {
        try doIfPossible(root: packages) {
            try wrappedValue.install(packages: packages)
        }
    }
}
