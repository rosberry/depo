//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

public protocol ProgressNotifier {
    associatedtype State

    func notify(_ state: State)
}
