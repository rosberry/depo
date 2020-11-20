//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

public final class DefaultProgressController<State>: ProgressObservable, ProgressNotifier {

    private var observer: ((State) -> Void)?

    public init() {}

    public func subscribe(_ observer: @escaping (State) -> Void) -> Self {
        self.observer = observer
        return self
    }

    public func notify(_ state: State) {
        observer?(state)
    }
}

extension DefaultProgressController: Codable {
    public convenience init(from decoder: Decoder) throws {
        self.init()
    }

    public func encode(to encoder: Encoder) throws {}
}
