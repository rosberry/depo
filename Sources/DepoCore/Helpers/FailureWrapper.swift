//
// Copyright © 2021 Rosberry. All rights reserved.
//

import Foundation

public protocol ErrorDescriptivePackage {
    var errorDescription: String { get }
}

extension Pod: ErrorDescriptivePackage {
    public var errorDescription: String {
        "Pod: \(name)"
    }
}

extension SwiftPackage: ErrorDescriptivePackage {
    public var errorDescription: String {
        "SwiftPackage: \(name): \(url.absoluteString)"
    }
}

extension CarthageItem: ErrorDescriptivePackage {
    public var errorDescription: String {
        "CarthageItem: \(identifier)"
    }
}


public struct FailureWrapper<Value, E: Swift.Error>: Error {

    public let error: E
    public let value: Value

    public var localizedDescription: String {
        error.localizedDescription
    }

    init(error: E, value: Value) {
        self.error = error
        self.value = value
    }
}

extension FailureWrapper: LocalizedError where E: LocalizedError {

    public var errorDescription: String? {
        if let value = value as? ErrorDescriptivePackage {
            return "Got <\(error.errorDescription ?? "undefined error")> for \(value.errorDescription)"
        }
        else {
            return error.errorDescription
        }
    }
}
