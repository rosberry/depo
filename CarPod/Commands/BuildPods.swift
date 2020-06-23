//
// Copyright (c) 2020 ___FULLUSERNAME___. All rights reserved.
//

import Foundation
import Commandant

struct BuildPodsCommand: CommandProtocol {

    let verb: String = "build"
    let function: String = "Test function"

    func run(_ options: NoOptions<CommandantError<()>>) -> Result<(), CommandantError<()>> {
        return .success(())
    }
}
