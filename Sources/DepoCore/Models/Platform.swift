//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

public enum Platform: String, HasDefaultValue, CaseIterable, RawRepresentable, Codable {

    case mac
    case ios
    case tvos
    case watchos

    public static let defaultValue: Platform = .ios

    var simulatorKey: String? {
        switch self {
        case .mac:
            return nil
        case .ios:
            return "iphonesimulator"
        case .tvos:
            return "appletvsimulator"
        case .watchos:
            return "watchsimulator"
        }
    }

    var deviceKey: String {
        switch self {
        case .mac:
            return "macosx"
        case .ios:
            return "iphoneos"
        case .tvos:
            return "appletvos"
        case .watchos:
            return "watchos"
        }
    }

    public init?(key: String) {
        switch key {
        case Self.mac.deviceKey,
             Self.mac.simulatorKey:
            self = .mac
        case Self.ios.deviceKey,
             Self.ios.simulatorKey:
            self = .ios
        case Self.tvos.deviceKey,
             Self.tvos.simulatorKey:
            self = .tvos
        case Self.watchos.deviceKey,
             Self.watchos.simulatorKey:
            self = .watchos
        default:
            return nil
        }
    }
}
