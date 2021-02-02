//
// Copyright © 2021 Rosberry. All rights reserved.
//

extension CarthageItem: GitIdentifiablePackage {
    public var packageID: GitCacher.PackageID {
        .init(name: String(self.identifier.split(separator: "/")[1]))
    }
}
