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

    init(path: String = FileManager.default.currentDirectoryPath + "/\(AppConfiguration.configFileName)") throws {
        guard let data = NSData(contentsOfFile: path) as Data? else {
            throw CustomError.badCarPodFileURL(path: path)
        }
        self = try JSONDecoder().decode(CarPodfile.self, from: data)
    }
}
