//
// Copyright © 2021 Rosberry. All rights reserved.
//

import Foundation

final class Git: ShellCommand {

    var git: Self {
        self
    }

    convenience init() {
        self.init(commandPath: "git")
    }

    public func checkout(_ gitReference: String) throws {
        let _: Int32 = try git("checkout \(gitReference)")
    }

    public func createBranch(name: String) throws {
        let _: Int32 = try git("branch \(name) master")
    }

    public func delete(branch: String) throws {
        let _: Int32 = try git("branch -D \(branch)")
    }

    public func add(_ items: String) throws {
        let _: Int32 = try git("add \(items)")
    }

    public func commit(message: String) throws {
        let _: Int32 = try git("commit -m \"\(message)\"")
    }

    public func currentBranch() throws -> String {
        let output: Shell.IO = try git("rev-parse --abbrev-ref HEAD")
        return output.stdOut.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    public func hasChanges() throws -> Bool {
        let output: Shell.IO = try git("status -s")
        return !output.stdOut.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    public func initialize() throws {
        let _: Int32 = try git("init")
    }
}
