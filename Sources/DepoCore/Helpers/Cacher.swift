//
// Copyright © 2021 Rosberry. All rights reserved.
//

import Foundation

struct XcodeCLTVersion {}
struct Package {
    let name: String
    let version: String
}

public protocol Cacher {
    associatedtype PackageID

    var packages: [PackageID] { get }
    
    func save(buildURL: URL, packageID: PackageID)
    func get(packageID: PackageID) -> URL
    func delete(packageID: PackageID)
}

public struct GitCacher: Cacher {
    public var packages: [PackageID]

    public struct PackageID: CustomStringConvertible {
        let name: String
        let version: String
        let xcodebuildVersion: XcodeCLTVersion
        public let description: String = ""
    }

    private let gitRepoURL: URL
    private let fmg: FileManager = .default
    private let git: Git = .init(commandPath: "git")
    
    init(gitRepoURL: URL) {
        self.gitRepoURL = gitRepoURL
        self.packages = []
    }

    public func save(buildURL: URL, packageID: PackageID) {
        fmg.perform(atPath: gitRepoURL.absoluteString) {
            git.createBranch(name: packageID.description)
            copyToCurrent(url: buildURL)
            stageEverything()
            commit(message: packageID.description)
            pushIfPossible()
        }
    }

    public func get(packageID: PackageID) -> URL {
        fmg.perform(atPath: gitRepoURL.absoluteString) {
            git.checkout(packageID.description)
            return findFrameworkInCurrentDir()
        }
    }

    public func delete(packageID: PackageID) {
        fmg.perform(atPath: gitRepoURL.absoluteString) {
            git.checkout("master")
            git.delete(branch: packageID.description)
        }
    }
    
    private func createBranch(name: String) {
        
    }

    private func copyToCurrent(url: URL) {

    }

    private func stageEverything() {

    }

    private func commit(message: String) {

    }

    private func pushIfPossible() {

    }

    private func branchName(from packageID: PackageID) -> String {
        fatalError()
    }

    private func checkout(branch: String) {

    }

    private func findFrameworkInCurrentDir() -> URL {
        fatalError()
    }
}

