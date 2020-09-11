//
// Copyright (c) 2020 ___FULLUSERNAME___. All rights reserved.
//

import Foundation

struct BuildSettings: Codable {

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
    private let buildSettings: [String: String]

    init(targetName: String, shell: Shell = .init(), decoder: JSONDecoder = .init()) throws {
        let output: Shell.Output = try shell("xcodebuild", "-showBuildSettings", "-json", "-target", targetName)
        guard let data = output.stdOut.data(using: .utf8) else {
            throw CustomError.badOutput
        }
        self.buildSettings = (try decoder.decode([BuildSettings].self, from: data)).first?.buildSettings ?? [:]
    }
}
