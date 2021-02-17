//
// Copyright © 2021 Rosberry. All rights reserved.
//

extension Pod: GitIdentifiablePackage {
    public func packageID(xcodeVersion: XcodeBuild.Version?) -> GitCacher.PackageID {
        .init(xbVersion: xcodeVersion?.xcodeVersion,
              name: name,
              version: versionConstraint?.value)
    }
}
