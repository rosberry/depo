//
// Copyright © 2021 Rosberry. All rights reserved.
//

extension SwiftPackage: GitIdentifiablePackage {
    public func packageID(xcodeVersion: XcodeBuild.Version?) -> GitCacher.PackageID {
        .init(name: self.name)
    }
}
