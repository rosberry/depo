//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import Yams
import ArgumentParser

public struct DataDecoder: TopLevelDecoder {
    typealias Input = Data

    public enum Kind: String, Codable, RawRepresentable, CaseIterable, HasDefaultValue, ExpressibleByArgument {
        case json
        case yaml

        public var decoder: DataDecoder {
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
}
