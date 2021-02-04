//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import DepoCore
import Files
import ArgumentParser
import PathKit

var processes: [Process] = []

Shell.processCreationHandler = { process in
    processes.append(process)
}

signal(SIGINT, SIG_IGN)

let source = DispatchSource.makeSignalSource(signal: SIGINT, queue: .main)
source.setEventHandler {
    for process in processes where process.isRunning {
        process.interrupt()
    }
    exit(SIGINT)
}
source.resume()

Depo.main()

struct Cacher: ParsableCommand {

    enum Error: Swift.Error {
        case invalidURL(string: String)
    }

    struct Save: ParsableCommand {

        @Option(name: .shortAndLong)
        var gitRepoURL: String

        @Option(name: .shortAndLong)
        var packageName: String

        @Argument
        var buildURLs: [String]

        func run() throws {
            let gitRepoURL = try URL.throwingInit(string: self.gitRepoURL)
            let buildURLs = try self.buildURLs.map { buildURL in
                try URL.throwingInit(string: Path(buildURL).absolute().string)
            }
            let cacher = GitCacher(gitRepoURL: gitRepoURL)
            try cacher.save(buildURLs: buildURLs, packageID: .init(name: packageName))
        }
    }

    struct Update: ParsableCommand {

        @Option(name: .shortAndLong)
        var gitRepoURL: String

        @Option(name: .shortAndLong)
        var packageName: String

        @Argument
        var buildURLs: [String]

        func run() throws {
            let gitRepoURL = try URL.throwingInit(string: self.gitRepoURL)
            let buildURLs = try self.buildURLs.map { buildURL in
                try URL.throwingInit(string: Path(buildURL).absolute().string)
            }
            let cacher = GitCacher(gitRepoURL: gitRepoURL)
            try cacher.update(buildURLs: buildURLs, packageID: .init(name: packageName))
        }
    }

    struct Get: ParsableCommand {

        @Option(name: .shortAndLong)
        var gitRepoURL: String

        @Option(name: .shortAndLong)
        var packageName: String

        func run() throws {
            let gitRepoURL = try URL.throwingInit(string: self.gitRepoURL)
            let cacher = GitCacher(gitRepoURL: gitRepoURL)
            let url = try cacher.get(packageID: .init(name: packageName))
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

    static let configuration: CommandConfiguration = .init(subcommands: [Save.self,
                                                                         Get.self,
                                                                         Setup.self,
                                                                         Update.self,
                                                                         Packages.self])
}

// Cacher.main()

//print(Folder.current.url.absoluteString)
//print(try Folder.current.subfolder(at: "/Users").url.absoluteString)

//let cacher = GitCacher(gitRepoURL: URL(string: "git@github.com:zhvrnkov/frameworks-store.git")!)
//print(try cacher.get(packageID: .init(name: "Framezilla")))

// print(try cacher.packageIDs())

// try cacher.setupRepository(remoteURL: URL(string: "https://github.com/zhvrnkov/frameworks-store.git"))

//let url = try cacher.get(packageID: .init(name: "Base-iOS"))
//print(url)
//
//try cacher.save(buildURL: URL(string: "file:///Users/vz/Developer/Core-iOS/Carthage/Build/iOS/Framezilla.framework")!,
//                packageID: .init(name: "Framezilla"))
//
// try cacher.delete(packageID: .init(name: "Framezilla"))
