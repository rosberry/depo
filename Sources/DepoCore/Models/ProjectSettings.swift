//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

public struct ProjectSettings: Codable {

    public enum Error: Swift.Error {
        case badOutput(io: Shell.IO)
    }

    private struct ShellOutputWrapper: Codable {
        let project: ProjectSettings
    }

    public let targets: [String]
    public let schemes: [String]
    public let name: String
    public let configurations: [String]

    public init(shell: Shell, decoder: JSONDecoder = .init()) throws {
        let io: Shell.IO = try shell("xcodebuild", "-list", "-json")
        guard let data = io.stdOut.data(using: .utf8) else {
            throw Error.badOutput(io: io)
        }
        self = try decoder.decode(ShellOutputWrapper.self, from: data).project
    }
}
