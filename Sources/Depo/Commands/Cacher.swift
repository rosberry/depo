//
// Copyright © 2021 Rosberry. All rights reserved.
//

import Foundation
import PathKit
import ArgumentParser
import DepoCore

struct Cacher: ParsableCommand {

    enum Error: Swift.Error {
        case invalidURL(string: String)
    }

    struct Save: ParsableCommand {

        @Option(name: .shortAndLong)
        var gitRepoURL: String

        @Option(name: .shortAndLong, help: "will be used as branch name")
        var packageIdentifier: String

        @Argument
        var buildURLs: [String]

        func run() throws {
            let gitRepoURL = try URL.throwingInit(string: self.gitRepoURL)
            let buildURLs = try self.buildURLs.map { buildURL in
                try URL.throwingInit(string: Path(buildURL).absolute().string)
            }
            let cacher = GitCacher(gitRepoURL: gitRepoURL)
            try cacher.save(buildURLs: buildURLs, packageID: .init(stringLiteral: packageIdentifier))
        }
    }

    struct Update: ParsableCommand {

        @Option(name: .shortAndLong)
        var gitRepoURL: String

        @Option(name: .shortAndLong, help: "will be used as branch name")
        var packageIdentifier: String

        @Argument
        var buildURLs: [String]

        func run() throws {
            let gitRepoURL = try URL.throwingInit(string: self.gitRepoURL)
            let buildURLs = try self.buildURLs.map { buildURL in
                try URL.throwingInit(string: Path(buildURL).absolute().string)
            }
            let cacher = GitCacher(gitRepoURL: gitRepoURL)
            try cacher.update(buildURLs: buildURLs, packageID: .init(stringLiteral: packageIdentifier))
        }
    }

    struct Get: ParsableCommand {

        @Option(name: .shortAndLong)
        var gitRepoURL: String

        @Option(name: .shortAndLong, help: "will be used as branch name")
        var packageIdentifier: String

        func run() throws {
            let gitRepoURL = try URL.throwingInit(string: self.gitRepoURL)
            let cacher = GitCacher(gitRepoURL: gitRepoURL)
            let url = try cacher.get(packageID: .init(stringLiteral: packageIdentifier))
            print(url)
        }
    }

    struct Setup: ParsableCommand {

        @Option(name: .shortAndLong)
        var localGitRepoURL: String

        @Option(name: .shortAndLong)
        var remoteGitRepoURL: String?

        func run() throws {
            let localGitRepoURL = try URL.throwingInit(string: self.localGitRepoURL)
            let remoteGitRepoURL = try? URL.throwingInit(string: self.remoteGitRepoURL ?? "")
            let cacher = GitCacher(gitRepoURL: localGitRepoURL)
            try cacher.setupRepository(at: localGitRepoURL, remoteURL: remoteGitRepoURL)
        }
    }

    struct Packages: ParsableCommand {

        @Option(name: .shortAndLong)
        var gitRepoURL: String

        func run() throws {
            let gitRepoURL = try URL.throwingInit(string: self.gitRepoURL)
            let cacher = GitCacher(gitRepoURL: gitRepoURL)
            print(try cacher.packageIDS().map(by: \.description).joined(separator: "\n"))
        }
    }

    static let configuration: CommandConfiguration = .init(abstract: "GitCacher clt interface",
                                                           subcommands: [Save.self,
                                                                         Get.self,
                                                                         Setup.self,
                                                                         Update.self,
                                                                         Packages.self])
}
