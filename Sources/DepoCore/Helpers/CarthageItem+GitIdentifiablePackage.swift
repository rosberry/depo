//
// Copyright © 2021 Rosberry. All rights reserved.
//

extension CarthageItem: GitIdentifiablePackage {
    public func packageID(xcodeVersion: XcodeBuild.Version?) -> GitCacher.PackageID {
        .init(xbVersion: xcodeVersion?.xcodeVersion,
              name: name,
              version: versionConstraint?.value)
    }

    private var name: String {
        let split = identifier.split(separator: "/")
        guard split.count > 1 else {
            return identifier
        }
        return String(split[1])
    }
}
