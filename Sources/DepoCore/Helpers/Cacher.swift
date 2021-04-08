//
// Copyright © 2021 Rosberry. All rights reserved.
//

import Foundation

public protocol Cacher {
    associatedtype PackageID

    func packageIDS() throws -> [PackageID]
    func save(buildURLs: [URL], packageID: PackageID) throws
    func update(buildURLs: [URL], packageID: PackageID) throws
    func get(packageID: PackageID) throws -> URL
    func delete(packageID: PackageID) throws
}

public enum CacherError<PackageID>: Error {
    case noChangesToSave(packageID: PackageID)
}
