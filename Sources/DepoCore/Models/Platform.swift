//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

public enum Platform: String, HasDefaultValue, CaseIterable, RawRepresentable, Codable {

    case mac
    case ios
    case tvos
    case watchos
    case all

    public static let defaultValue: Platform = .ios
}
