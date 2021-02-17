//
//  Copyright © 2021 Rosberry. All rights reserved.
//

import Foundation

struct PackageManagerWrapper {

    private let xcodebuildVersion: XcodeBuild.Version? = {
        try? XcodeBuild(shell: .init()).version()
    }()

    func classAsFunction<Manager: HasAllCommands>(
            manager: Manager,
            keyPath: KeyPath<[Manager.Package], Bool>,
            cacheBuilds: Bool
    ) -> AnyPackageManager<Manager.Package>
            where Manager.Package: GitIdentifiablePackage {
        let conditionalPM = ConditionalPackageManager(wrappedValue: manager, keyPath: keyPath)
        fatalError()
        if cacheBuilds {
            let gitCachablePM = GitCachablePackageManager(wrappedValue: conditionalPM,
                                                          xcodebuildVersion: xcodebuildVersion)
            return .init(outputPath: gitCachablePM.outputPath,
                         buildClosure: gitCachablePM.build,
                         installClosure: gitCachablePM.install,
                         updateClosure: gitCachablePM.update)
        }
        else {
            return .init(outputPath: conditionalPM.outputPath,
                         buildClosure: conditionalPM.build,
                         installClosure: conditionalPM.install,
                         updateClosure: conditionalPM.update)
        }
    }

    func callAsFunction<Manager: HasBuildCommand & HasUpdateCommand>(
            manager: Manager,
            keyPath: KeyPath<[Manager.Package], Bool>,
            cacheBuilds: Bool
    ) -> AnyPackageManager<Manager.Package>
            where Manager.Package: GitIdentifiablePackage {
        let conditionalPM = ConditionalPackageManager(wrappedValue: manager, keyPath: keyPath)
        if cacheBuilds {
            let gitCachablePM = GitCachablePackageManager(wrappedValue: conditionalPM,
                                                          xcodebuildVersion: xcodebuildVersion)
            return .init(outputPath: gitCachablePM.outputPath,
                         buildClosure: gitCachablePM.build,
                         installClosure: gitCachablePM.update,
                         updateClosure: gitCachablePM.update)
        }
        else {
            return .init(outputPath: conditionalPM.outputPath,
                         buildClosure: conditionalPM.build,
                         installClosure: conditionalPM.update,
                         updateClosure: conditionalPM.update)
        }
    }
}
