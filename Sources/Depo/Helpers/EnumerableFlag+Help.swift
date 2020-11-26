//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import ArgumentParser
import DepoCore

extension CaseIterable where Self: RawRepresentable, Self.RawValue: CustomStringConvertible {

    static var allFlagsHelp: String {
        allCases.map(by: \.rawValue.description).joined(separator: "|")
    }
}