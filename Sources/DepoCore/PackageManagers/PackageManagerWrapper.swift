//
//  Copyright © 2021 Rosberry. All rights reserved.
//

import Foundation

public struct PackageManagerWrapper {

    private let xcodebuildVersion: XcodeBuild.Version? = {
        try? XcodeBuild(shell: .init()).version()
    }()

    public init() {}

    public func wrap<PM: PackageManager>(
            packages: [PM.Package],
            keyPath: KeyPath<[PM.Package], Bool> = \.isEmpty.not,
            cacheBuilds: Bool,
            factory: @escaping ([PM.Package]) -> PM
    ) -> AnyPackageManager<PM.Package>
            where PM.Package: GitIdentifiablePackage {
        let conditionalPMFactory = { packages in
            ConditionalPackageManager(packages: packages, packageManagerFactory: factory, keyPath: keyPath)
        }
        if cacheBuilds {
            let gitCachablePM = GitCachablePackageManager(packages: packages,
                                                          packageManagerFactory: conditionalPMFactory,
                                                          xcodebuildVersion: xcodebuildVersion)
            return gitCachablePM.eraseToAny()
        }
        else {
            return conditionalPMFactory(packages).eraseToAny()
        }
    }
}
