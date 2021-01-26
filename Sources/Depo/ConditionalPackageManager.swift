//
// Copyright © 2020 Rosberry. All rights reserved.
//

@propertyWrapper
struct ConditionalPackageManager<PackageManager> {

    let wrappedValue: PackageManager
    let condition: () -> Bool

    private func doIfPossible(action: () throws -> Void) throws {
        guard condition() else {
            return
        }
        try action()
    }
}

extension ConditionalPackageManager {
    init<R>(wrappedValue: PackageManager, root: R, keyPath: KeyPath<R, Bool>) {
        self.wrappedValue = wrappedValue
        self.condition = {
            root[keyPath: keyPath]
        }
    }
}

extension ConditionalPackageManager where PackageManager: HasUpdateCommand {
    func updateIfPossible() throws {
        try doIfPossible {
            try wrappedValue.update()
        }
    }
}

extension ConditionalPackageManager where PackageManager: HasBuildCommand {
    func buildIfPossible() throws {
        try doIfPossible {
            try wrappedValue.build()
        }
    }
}

extension ConditionalPackageManager where PackageManager: HasInstallCommand {
    func installIfPossible() throws {
        try doIfPossible {
            try wrappedValue.install()
        }
    }
}
