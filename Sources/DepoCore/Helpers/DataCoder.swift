//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import Yams
import ArgumentParser

public struct DataCoder: TopLevelDecoder, TopLevelEncoder {
    public typealias Input = Data
    public typealias Output = Data

    public enum Kind: String, Codable, RawRepresentable, CaseIterable, HasDefaultValue, ExpressibleByArgument {
        case json
        case yaml

        public var coder: DataCoder {
            .init(kind: self)
        }

        public static let defaultValue: Kind = .yaml
    }

    private let kind: Kind

    public init(kind: Kind) {
        self.kind = kind
    }

    public func decode<T>(_ type: T.Type, from input: Input) throws -> T where T: Decodable {
        switch kind {
        case .json:
            return try JSONDecoder().decode(type, from: input)
        case .yaml:
            return try YAMLDecoder().decode(type, from: input)
        }
    }

    public func encode<T: Encodable>(_ object: T) throws -> Output {
        switch kind {
        case .json:
            return try JSONEncoder().encode(object)
        case .yaml:
            let yamlString = try YAMLEncoder().encode(object)
            guard let yamlData = yamlString.data(using: .utf8) else {
                throw EncodingError.invalidValue(yamlString, .init(codingPath: [], debugDescription: "unable to map string to data"))
            }
            return yamlData
        }
    }
}
