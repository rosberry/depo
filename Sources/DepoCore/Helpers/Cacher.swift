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
    func get(packageID: PackageID) throws -> URL
}

public enum CacherError<PackageID>: Error {
    case noChangesToSave(packageID: PackageID)
}

public struct GitRemoteCacher: Cacher {

    public typealias PackageID = GitCacher.PackageID

    // MARK: copy paste
    public enum Error: Swift.Error {
        case unableToCheckoutOrCreate(branch: String)
    }

    private let gitRemoteRepoURL: URL
    private let git: Git = .init()
    private let fmg: FileManager = .default

    public init(gitRemoteRepoURL: URL) {
        self.gitRemoteRepoURL = gitRemoteRepoURL
    }

    public func get(packageID: PackageID) throws -> URL {
        try git.clone(url: gitRemoteRepoURL, to: packageID.description, branchName: packageID.description)
        return try Folder.current.subfolder(named: packageID.description).url
    }

    public func save(buildURL: URL, packageID: PackageID) throws {
        try git.clone(url: gitRemoteRepoURL, to: packageID.description, branchName: Git.masterBranchName)
        try fmg.perform(atPath: packageID.description) {
            try checkoutBranchAndCreateIfNeeded(name: packageID.description)
            try Folder.current.deleteContents()
            try copyToCurrent(url: buildURL)
            try throwIfNoChanges(packageID: packageID)
            try git.add(".")
            try git.commit(message: packageID.description)
            try git.push(remote: Git.remoteName, branch: packageID.description)
        }
    }

    // MARK: copy paster
    private func checkoutBranchAndCreateIfNeeded(name: String) throws {
        try? git.createBranch(name: name)
        try? git.checkout(name)
        guard try git.currentBranch() == name else {
            throw Error.unableToCheckoutOrCreate(branch: name)
        }
    }

    // copy paste
    private func copyToCurrent(url: URL) throws {
        if let folder = try? Folder(path: url.path) {
            try folder.copy(to: Folder.current)
        }
        else {
            let file = try File(path: url.path)
            try file.copy(to: Folder.current)
        }
    }

    // copy paste
    private func throwIfNoChanges(packageID: PackageID) throws {
        guard try git.hasChanges() else {
            throw CacherError.noChangesToSave(packageID: packageID)
        }
    }
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

    public enum Error: Swift.Error {
        case unableToCheckoutOrCreate(branch: String)
    }

    private let localGitRepoURL: URL
    private let fmg: FileManager = .default
    private let git: Git

    public init(localGitRepoURL: URL) {
        self.git = .init(commandPath: "git")
        self.localGitRepoURL = localGitRepoURL
    }

    public init(remoteGitRepoURL: URL) throws {
        let git = Git(commandPath: "git")
        self.git = git
        self.localGitRepoURL = try Self.cloneRepository(remoteURL: remoteGitRepoURL, git: git)
    }

    public func setupRepository(remoteURL: URL?) throws {
        try fmg.perform(atPath: localGitRepoURL.path) {
            try git.initialize()
            try Folder.current.createFile(named: ".gitkeep")
            try git.add(".")
            try git.commit(message: "Initial commit")
            try addRemoteIfNeeded(url: remoteURL)
        }
    }

    public func save(buildURL: URL, packageID: PackageID) throws {
        let packageBranch = packageID.description
        try fmg.perform(atPath: localGitRepoURL.path) {
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
        try fmg.perform(atPath: localGitRepoURL.path) {
            try git.checkout(packageID.description)
            return findFrameworkInCurrentDir()
        }
    }

    public func delete(packageID: PackageID) throws {
        try fmg.perform(atPath: localGitRepoURL.path) {
            try git.checkout(Git.masterBranchName)
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

    private static func cloneRepository(remoteURL: URL, git: Git) throws -> URL {
        let name = remoteURL.gitRepoName
        try? Folder(path: name).delete()
        fatalError()
        // try git.clone(url: remoteURL, to: name, branchName: <#T##String##Swift.String#>)
        return try Folder.current.subfolder(named: name).url
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
