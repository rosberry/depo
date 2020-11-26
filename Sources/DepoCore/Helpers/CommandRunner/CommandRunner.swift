//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import ArgumentParser

protocol Command {
    func run() throws
}

struct CommandRunner {

    @_functionBuilder
    struct Builder {
        static func buildBlock(_ partialResults: () throws -> Void...) -> [Swift.Error] {
            partialResults.compactMap { closure in
                do {
                    try closure()
                    return nil
                }
                catch {
                    return error
                }
            }
        }

        static func buildBlock(_ commands: Command & AnyObject...) -> [Swift.Error] {
            var c = commands
            return c.indices.compactMap { index in
                do {
                    try c[index].run()
                    return nil
                }
                catch {
                    return error
                }
            }
        }
    }

    static func runIndependently(@Builder build: () -> [Swift.Error]) throws {
        let errors = build()
        guard errors.isEmpty else {
            throw CompositeError(errors: errors)
        }
    }
}
