//
// Copyright © 2021 Rosberry. All rights reserved.
//

import Foundation

func separate<S, F: Swift.Error>(_ array: [Result<S, F>]) -> ([S], [F]) {
    array.reduce(([S](), [F]())) { result, item in
        let (successes, failures) = result
        switch item {
        case let .success(success):
            return (successes + [success], failures)
        case let .failure(failure):
            return (successes, failures + [failure])
        }
    }
}
