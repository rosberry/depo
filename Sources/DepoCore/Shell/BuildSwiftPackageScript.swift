//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

public final class BuildSwiftPackageScript: ShellCommand {

    public override init(commandPath: String = AppConfiguration.Path.Absolute.buildSPShellScript, shell: Shell) {
        super.init(commandPath: commandPath, shell: shell)
    }

    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }

    @discardableResult
    public func callAsFunction(teamID: String, buildDir: String, target: String) throws -> Shell.IO {
        try shell(filePath: commandPath, arguments: [teamID, buildDir, target])
    }
}
