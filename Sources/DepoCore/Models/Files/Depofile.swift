//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

public struct Depofile: Codable {

    enum CustomError: LocalizedError {
        case badDepoFileURL(path: String)
    }

    public let pods: [Pod]
    public let carts: [CarthageItem]
    public let swiftPackages: [SwiftPackage]
    public static let defaultPath: String = "./\(AppConfiguration.configFileName)"

    public init(pods: [Pod], carts: [CarthageItem], swiftPackages: [SwiftPackage]) {
        self.pods = pods
        self.carts = carts
        self.swiftPackages = swiftPackages
    }
}

public extension Depofile {
    init<D: TopLevelDecoder>(path: String = defaultPath, fileManager: FileManager = .default, decoder: D) throws where D.Input == Data {
        guard let data = fileManager.contents(atPath: path) else {
            throw CustomError.badDepoFileURL(path: path)
        }
        self = try decoder.decode(Depofile.self, from: data)
    }
}
