//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import DepoCore

extension BuildSettings.Error: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .badOutput(io):
            return "cannot parse output of \(io.command.joined(separator: " "))"
        case let .badBuildSettings(missedKey, settings):
            return "cannot find key \(missedKey) in \(json(settings))"
        }
    }

    private func json(_ dictionary: [String: String]) -> String {
        guard let data = try? JSONEncoder().encode(dictionary) else {
            return "invalid json"
        }
        return String(data: data, encoding: .utf8) ?? "invalid json"
    }
}
