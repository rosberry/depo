//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

public struct XcodeProjectList: Codable {

    public enum Error: Swift.Error {
        case badOutput(shellIO: Shell.IO)
    }

    private struct List: Codable {
        let project: XcodeProjectList
    }

    public let name: String
    public let configurations: [String]
    public let schemes: [String]
    public let targets: [String]

    public init(name: String? = nil, decoder: JSONDecoder = .init(), shell: Shell = .init()) throws {
        let output: Shell.IO
        if let name = name {
            output = try shell(silent: "xcodebuild -list -json -project \(name)")
        }
        else {
            output = try shell(silent: "xcodebuild -list -json")
        }
        guard let data = output.stdOut.data(using: .utf8) else {
            throw Error.badOutput(shellIO: output)
        }
        self = try decoder.decode(List.self, from: data).project
    }
}
