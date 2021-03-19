//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

public struct Depofile {

    enum CustomError: LocalizedError {
        case badDepoFileURL(path: String)
    }

    private enum CodingKeys: String, CodingKey {
        case pods
        case swiftPackages
        case carts
    }

    public let pods: [Pod]
    public let carts: [CarthageItem]
    public let swiftPackages: [SwiftPackage]
    public static let defaultPath: String = "./\(AppConfiguration.Name.config)"

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

extension Depofile: Codable {

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        pods = try container.decodeIfPresent([Pod].self, forKey: .pods) ?? []
        carts = try container.decodeIfPresent([CarthageItem].self, forKey: .carts) ?? []
        swiftPackages = try container.decodeIfPresent([SwiftPackage].self, forKey: .swiftPackages) ?? []
    }
}

extension Depofile: GitIdentifiablePackage {
    public func packageID(xcodeVersion: XcodeBuild.Version?) -> GitCacher.PackageID {
        ""
    }
}
