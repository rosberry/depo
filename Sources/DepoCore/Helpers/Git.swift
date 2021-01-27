//
// Copyright © 2021 Rosberry. All rights reserved.
//

import Foundation

final class Git: ShellCommand {

    convenience init() {
        self.init(commandPath: "git")
    }

    public func checkout(_ gitReference: String) throws {
        let _: Int32 = try self("checkout \(gitReference)")
    }

    public func createBranch(name: String) throws {
        let _: Int32 = try self("branch \(name) master")
    }

    public func delete(branch: String) throws {
        let _: Int32 = try self("branch -D \(branch)")
    }

    public func add(_ items: String) throws {
        let _: Int32 = try self("add \(items)")
    }

    public func commit(message: String) throws {
        let _: Int32 = try self("commit -m \"\(message)\"")
    }
}
