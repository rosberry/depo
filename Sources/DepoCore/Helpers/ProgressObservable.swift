//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

public protocol ProgressObservable {
    associatedtype State

    func subscribe(_ observer: @escaping (State) -> Void) -> Self
}
