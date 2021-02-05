//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import DepoCore
import Files
import ArgumentParser
import PathKit

var processes: [Process] = []

Shell.processCreationHandler = { process in
    processes.append(process)
}

signal(SIGINT, SIG_IGN)

let source = DispatchSource.makeSignalSource(signal: SIGINT, queue: .main)
source.setEventHandler {
    for process in processes where process.isRunning {
        process.interrupt()
    }
    exit(SIGINT)
}
source.resume()

Depo.main()
