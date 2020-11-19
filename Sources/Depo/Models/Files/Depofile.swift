//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

struct Depofile: Codable {

    enum CustomError: LocalizedError {
        case badDepoFileURL(path: String)
    }

    let pods: [Pod]
    let carts: [CarthageItem]
    let swiftPackages: [SwiftPackage]
    private static let defaultPath: String = "./\(AppConfiguration.Name.config)"

    init<D: TopLevelDecoder>(path: String = defaultPath, fileManager: FileManager = .default, decoder: D) throws where D.Input == Data {
        guard let data = fileManager.contents(atPath: path) else {
            throw CustomError.badDepoFileURL(path: path)
        }
        self = try decoder.decode(Depofile.self, from: data)
    }
}
