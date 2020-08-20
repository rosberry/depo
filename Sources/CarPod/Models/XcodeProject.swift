//
// Copyright (c) 2020 ___FULLUSERNAME___. All rights reserved.
//

import Foundation

struct XcodeProject: Codable {

    enum CustomError: Error {
        case badData
    }

    private struct List: Codable {
        let project: XcodeProject
    }

    let name: String
    let configurations: [String]
    let schemes: [String]
    let targets: [String]

    init(name: String? = nil, decoder: JSONDecoder = .init(), shell: Shell = .init()) throws {
        let output: Shell.Output
        if let name = name {
            output = try shell("xcodebuild", "-list", "-json", "-project", name)
        }
        else {
            output = try shell("xcodebuild", "-list", "-json")
        }
        guard let data = output.stdOut.data(using: .utf8) else {
            throw CustomError.badData
        }
        self = try decoder.decode(List.self, from: data).project
    }
}
