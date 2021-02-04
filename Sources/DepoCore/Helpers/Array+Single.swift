//
// Copyright © 2021 Rosberry. All rights reserved.
//

extension Array {
    struct NotSingle: Swift.Error {}

    func single() throws -> Element {
        guard self.count == 1,
              let first = self.first else {
            throw NotSingle()
        }
        return first
    }
}
