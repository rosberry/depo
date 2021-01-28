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
        try git.clone(url: gitRepoURL, to: packageID.description, branchName: packageID.description)
        return try fmg.perform(atPath: "./\(packageID.description)") {
            try findFrameworkInCurrentDir()
        }
    }

    public func save(buildURL: URL, packageID: PackageID) throws {
        try git.clone(url: gitRepoURL, to: packageID.description, branchName: Git.masterBranchName)
        try fmg.perform(atPath: packageID.description) {
            try checkoutBranchAndCreateIfNeeded(name: packageID.description)
            try Folder.current.deleteContents()
            try copyToCurrent(url: buildURL)
            try throwIfNoChanges(packageID: packageID)
            try git.add(".")
            try git.commit(message: packageID.description)
            try pushIfPossible(packageID: packageID)
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

    private func findFrameworkInCurrentDir() throws -> URL {
        let frameworks = Folder.current.subfolders.filter(by: "framework", at: \.extension)
        guard let framework = frameworks.first,
              frameworks.count == 1 else {
            throw Error.multipleFrameworks(path: fmg.currentDirectoryPath)
        }
        return framework.url
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
}

fileprivate extension URL {
    var gitRepoName: String {
        let splitted = lastPathComponent.split(separator: ".")
        return splitted[0...(splitted.count - 2)].reduce("") { result, substring in
            result + substring
        }
    }
}
