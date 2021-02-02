//
// Copyright © 2021 Rosberry. All rights reserved.
//

extension Pod: GitIdentifiablePackage {
    public var packageID: GitCacher.PackageID {
        .init(name: String(self.name))
    }
}
