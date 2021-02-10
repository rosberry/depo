//
// Copyright © 2021 Rosberry. All rights reserved.
//

extension Pod: GitIdentifiablePackage {
    public func packageID(xcodeVersion: XcodeBuild.Version?) -> GitCacher.PackageID {
        .init(name: String(self.name))
    }
}
