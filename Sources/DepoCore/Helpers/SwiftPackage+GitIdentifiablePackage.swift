//
// Copyright © 2021 Rosberry. All rights reserved.
//

extension SwiftPackage: GitIdentifiablePackage {
    public var packageID: GitCacher.PackageID {
        .init(name: self.name)
    }
}
