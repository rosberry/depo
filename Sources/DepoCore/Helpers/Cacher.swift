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

    func save(buildURL: URL, packageID: PackageID) throws
    func update(buildURL: URL, packageID: PackageID) throws
    func get(packageID: PackageID) throws -> URL
    func delete(packageID: PackageID) throws
}

public enum CacherError<PackageID>: Error {
    case noChangesToSave(packageID: PackageID)
}

public struct GitCacher: Cacher {

    public struct PackageID: CustomStringConvertible, ExpressibleByStringLiteral {

        public typealias StringLiteralType = String

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

        public init(stringLiteral value: StringLiteralType) {
            self.name = value
            self.version = ""
            self.xcodebuildVersion = .init()
        }
    }

    // MARK: copy paste
    public enum Error: Swift.Error {
        case unableToCheckoutOrCreate(branch: String)
        case multipleFrameworks(path: String)
        case multipleRemotes(path: String)
    }

    private let gitRepoURL: URL
    private let git: Git = .init()
    private let fmg: FileManager = .default

    public init(gitRepoURL: URL) {
        self.gitRepoURL = gitRepoURL
    }

    public func setupRepository(at localURL: URL, remoteURL: URL?) throws {
        try fmg.perform(atPath: localURL.path) {
            try git.initialize()
            try Folder.current.createFile(named: ".gitkeep")
            try git.add(".")
            try git.commit(message: "Initial commit")
            try addRemoteIfNeeded(url: remoteURL)
        }
    }

    public func get(packageID: PackageID) throws -> URL {
        let id = packageID.description
        try? deleteFolder(name: id)
        try git.clone(url: gitRepoURL, to: packageID.description, branchName: packageID.description)
        return try fmg.perform(atPath: "./\(packageID.description)") {
            Folder.current.url
        }
    }

    public func save(buildURL: URL, packageID: PackageID) throws {
        let id = packageID.description
        defer {
            try? deleteFolder(name: id)
        }
        try? deleteFolder(name: id)
        try git.clone(url: gitRepoURL, to: id, branchName: Git.masterBranchName)
        try fmg.perform(atPath: id) {
            try git.createBranch(name: id)
            try git.checkout(id)
            try Folder.current.deleteContents()
            try copyToCurrent(url: buildURL)
            try throwIfNoChanges(packageID: packageID)
            try git.add(".")
            try git.commit(message: id)
            try pushIfPossible(packageID: packageID)
        }
    }

    public func update(buildURL: URL, packageID: PackageID) throws {
        let id = packageID.description
        defer {
            try? deleteFolder(name: id)
        }
        try? deleteFolder(name: id)
        try git.clone(url: gitRepoURL, to: id, branchName: id)
        try fmg.perform(atPath: id) {
            try Folder.current.deleteContents()
            try copyToCurrent(url: buildURL)
            try throwIfNoChanges(packageID: packageID)
            try git.add(".")
            try git.commit(message: id)
            try pushIfPossible(packageID: packageID)
        }
    }

    public func delete(packageID: PackageID) throws {
        let id = packageID.description
        defer {
            try? deleteFolder(name: id)
        }
        try? deleteFolder(name: id)
        try git.clone(url: gitRepoURL, to: id, branchName: id)
        try fmg.perform(atPath: id) {
            try git.delete(remoteBranch: id)
        }
    }

    private func copyToCurrent(url: URL) throws {
        let string = url.absoluteString
        let absolutePath = (string as NSString).isAbsolutePath ? string : Folder.current.path + string
        if let folder = try? Folder(path: absolutePath) {
            try folder.copy(to: Folder.current)
        }
        else {
            let file = try File(path: absolutePath)
            try file.copy(to: Folder.current)
        }
    }

    private func throwIfNoChanges(packageID: PackageID) throws {
        guard try git.hasChanges() else {
            throw CacherError.noChangesToSave(packageID: packageID)
        }
    }

    private func addRemoteIfNeeded(url: URL?) throws {
        guard let url = url else {
            return
        }
        try git.remote.add(name: Git.defaultRemoteName, url: url)
    }

    private func pushIfPossible(packageID: PackageID) throws {
        let remotes = try git.remote()
        guard let remote = remotes.first,
              remotes.count == 1 else {
            throw Error.multipleRemotes(path: fmg.currentDirectoryPath)
        }
        try git.push(remote: remote, branch: packageID.description)
    }

    private func deleteFolder(name: String) throws {
        try Folder.current.subfolder(named: name).delete()
    }
}

fileprivate extension URL {
    var gitRepoName: String {
        let splitted = lastPathComponent.split(separator: ".")
        return splitted[0...(splitted.count - 2)].reduce("") { result, substring in
            result + substring
        }
    }
}
