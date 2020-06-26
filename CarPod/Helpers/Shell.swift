//
// Copyright (c) 2020 ___FULLUSERNAME___. All rights reserved.
//

import Foundation

@discardableResult
func shell(_ args: String...) -> Int32 {
    let task = Process()
    task.launchPath = "/usr/bin/env"
    task.arguments = args
    task.launch()
    task.waitUntilExit()
    return task.terminationStatus
}

@discardableResult
func shell(filePath: String, arguments: [String] = []) -> Int32 {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: filePath)
    process.arguments = arguments
    process.launch()
    process.waitUntilExit()
    return process.terminationStatus
}
