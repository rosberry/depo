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

extension ConditionalPackageManager: HasUpdateCommand where PackageManager: HasUpdateCommand {
    func update() throws {
        try doIfPossible {
            try wrappedValue.update()
        }
    }
}

extension ConditionalPackageManager: HasBuildCommand where PackageManager: HasBuildCommand {
    func build() throws {
        try doIfPossible {
            try wrappedValue.build()
        }
    }
}

extension ConditionalPackageManager: HasInstallCommand where PackageManager: HasInstallCommand {
    func install() throws {
        try doIfPossible {
            try wrappedValue.install()
        }
    }
}
