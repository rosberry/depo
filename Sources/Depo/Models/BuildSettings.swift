//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

final class BuildSettings: Codable {

    enum CustomError: Error {
        case badOutput
    }

    var productName: String {
        buildSettings["PRODUCT_NAME", default: ""]
    }
    var wrapperName: String {
        buildSettings["WRAPPER_NAME", default: ""]
    }
    var codesigningFolderPath: URL? {
        URL(string: buildSettings["CODESIGNING_FOLDER_PATH", default: ""])
    }
    var swiftVersion: String {
        buildSettings["SWIFT_VERSION", default: ""]
    }
    var targetName: String {
        buildSettings["TARGETNAME", default: ""]
    }

    private let buildSettings: [String: String]

    init(targetName: String?, shell: Shell = .init(), decoder: JSONDecoder = .init()) throws {
        let command = ["xcodebuild", "-showBuildSettings", "-json"] + (targetName.map { target in
            ["-target", target]
        } ?? [])
        let output: Shell.Output = try shell(command)
        guard let data = output.stdOut.data(using: .utf8) else {
            throw CustomError.badOutput
        }
        self.buildSettings = (try decoder.decode([BuildSettings].self, from: data)).first?.buildSettings ?? [:]
    }
}
