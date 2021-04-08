//
//  Copyright © 2021 Rosberry. All rights reserved.
//

import Foundation

public struct PackageManagerWrapper {

    enum Error: Swift.Error {
        case cacheBuildsButNoCacheURL
    }

    private let xcodebuildVersion: XcodeBuild.Version? = {
        try? XcodeBuild(shell: .init()).version()
    }()

    public init() {}

    public func wrap<PM: PackageManager>(
            packages: [PM.Package],
            keyPath: KeyPath<[PM.Package], Bool> = \.isEmpty.not,
            cacheBuilds: Bool,
            cacheURL: URL?,
            factory: @escaping ([PM.Package]) -> PM
    ) throws -> AnyPackageManager<PM.Package>
            where PM.Package: GitIdentifiablePackage {
        let conditionalPMFactory = { packages in
            ConditionalPackageManager(packages: packages, packageManagerFactory: factory, conditionKeyPath: keyPath)
        }
        if cacheBuilds {
            guard let cacheURL = cacheURL else {
                throw Error.cacheBuildsButNoCacheURL
            }
            let gitCachablePM = GitCachablePackageManager(packages: packages,
                                                          packageManagerFactory: conditionalPMFactory,
                                                          xcodebuildVersion: xcodebuildVersion,
                                                          cacheURL: cacheURL)
            return gitCachablePM.eraseToAny()
        }
        else {
            return conditionalPMFactory(packages).eraseToAny()
        }
    }
}
