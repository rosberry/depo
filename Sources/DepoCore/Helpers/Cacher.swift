//
// Copyright © 2021 Rosberry. All rights reserved.
//

import Foundation
import Files

struct XcodeCLTVersion {
}

struct Package {
    let name: String
    let version: String
}

public protocol Cacher {
    associatedtype PackageID

    var packages: [PackageID] { get }

    func save(buildURL: URL, packageID: PackageID) throws
    func get(packageID: PackageID) throws -> URL
    func delete(packageID: PackageID) throws
}

public enum CacherError<PackageID>: Error {
    case noChangesToSave(packageID: PackageID)
}

public struct GitCacher: Cacher {
    public var packages: [PackageID]

    public struct PackageID: CustomStringConvertible {
        let name: String
        let version: String
        let xcodebuildVersion: XcodeCLTVersion
        public var description: String {
            "\(name)"
        }

        public init(name: String) {
            self.name = name
            self.version = ""
            self.xcodebuildVersion = .init()
        }
    }

    public enum Error: Swift.Error {
        case unableToCheckoutOrCreate(branch: String)
    }

    private let gitRepoURL: URL
    private let fmg: FileManager = .default
    private let git: Git = .init(commandPath: "git")

    public init(gitRepoURL: URL) {
        self.gitRepoURL = gitRepoURL
        self.packages = []
    }

    public func setupRepository(remoteURL: URL?) throws {
        try fmg.perform(atPath: gitRepoURL.path) {
            try git.initialize()
            try Folder.current.createFile(named: ".gitkeep")
            try git.add(".")
            try git.commit(message: "Initial commit")
            try addRemoteIfNeeded(url: remoteURL)
        }
    }

    public func save(buildURL: URL, packageID: PackageID) throws {
        let packageBranch = packageID.description
        try fmg.perform(atPath: gitRepoURL.path) {
            try checkoutBranchAndCreateIfNeeded(name: packageBranch)
            try Folder.current.deleteContents()
            try copyToCurrent(url: buildURL)
            try throwIfNoChanges(packageID: packageID)
            try git.add(".")
            try git.commit(message: packageBranch)
            pushIfPossible()
        }
    }

    public func get(packageID: PackageID) throws -> URL {
        try fmg.perform(atPath: gitRepoURL.path) {
            try git.checkout(packageID.description)
            return findFrameworkInCurrentDir()
        }
    }

    public func delete(packageID: PackageID) throws {
        try fmg.perform(atPath: gitRepoURL.path) {
            try git.checkout("master")
            try git.delete(branch: packageID.description)
        }
    }

    private func checkoutBranchAndCreateIfNeeded(name: String) throws {
        try? git.createBranch(name: name)
        try? git.checkout(name)
        guard try git.currentBranch() == name else {
            throw Error.unableToCheckoutOrCreate(branch: name)
        }
    }

    private func throwIfNoChanges(packageID: PackageID) throws {
        guard try git.hasChanges() else {
            throw CacherError.noChangesToSave(packageID: packageID)
        }
    }

    private func copyToCurrent(url: URL) throws {
        if let folder = try? Folder(path: url.path) {
            try folder.copy(to: Folder.current)
        }
        else {
            let file = try File(path: url.path)
            try file.copy(to: Folder.current)
        }
    }

    private func findFrameworkInCurrentDir() -> URL {
        let frameworks = Folder.current.subfolders.filter(by: "framework", at: \.extension)
        guard let framework = frameworks.first,
              frameworks.count == 1 else {
            fatalError("multiple frameworks")
        }
        return framework.url
    }

    private func addRemoteIfNeeded(url: URL?) throws {
        guard let url = url else {
            return
        }
        try git.remote.add(name: "origin", url: url)
    }

    private func pushIfPossible() {

    }

}
