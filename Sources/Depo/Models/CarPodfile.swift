//
// Copyright (c) 2020 ___FULLUSERNAME___. All rights reserved.
//

import Foundation

struct CarPodfile: Codable {

    enum CustomError: LocalizedError {
        case badCarPodFileURL(path: String)
    }

    let pods: [Pod]
    let carts: [CarthageItem]
    private static let defaultPath: String = "./\(AppConfiguration.configFileName)"

    init<D: TopLevelDecoder>(path: String = defaultPath, fileManager: FileManager = .default, decoder: D) throws where D.Input == Data {
        guard let data = fileManager.contents(atPath: path) else {
            throw CustomError.badCarPodFileURL(path: path)
        }
        self = try decoder.decode(CarPodfile.self, from: data)
    }
}
