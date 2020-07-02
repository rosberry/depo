//
// Copyright (c) 2020 ___FULLUSERNAME___. All rights reserved.
//

import Foundation

struct Shell: Codable {

    struct Output {
        let stdOut: String
        let stdErr: String
        let stdIn: String
        let status: Int32

        fileprivate init(_ values: [String], status: Int32) {
            precondition(values.count == 3)
            self.stdOut = values[0]
            self.stdErr = values[1]
            self.stdIn = values[2]
            self.status = status
        }
    }

    func callAsFunction(_ args: String...) -> Int32 {
        let process = Process()
        process.launchPath = "/usr/bin/env"
        process.arguments = args
        return terminationStatus(of: process)
    }

    func callAsFunction(filePath: String, arguments: [String] = []) -> Int32 {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: filePath)
        process.arguments = arguments
        return terminationStatus(of: process)
    }

    func callAsFunction(_ args: String...) throws -> Output {
        let process = Process()
        process.launchPath = "/usr/bin/env"
        process.arguments = args
        return try output(of: process)
    }

    func callAsFunction(filePath: String, arguments: [String] = []) throws -> Output {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: filePath)
        process.arguments = arguments
        return try output(of: process)
    }

    private func output(of process: Process) throws -> Output {
        let stdOutPipe = Pipe()
        let stdErrPipe = Pipe()
        let stdInFileHandle = FileHandle()
        process.standardOutput = stdOutPipe
        process.standardError = stdErrPipe
        process.standardInput = stdInFileHandle
        try process.run()
        process.waitUntilExit()
        return Output([stdOutPipe.fileHandleForReading, stdErrPipe.fileHandleForReading, stdInFileHandle].map { handler in
            let outputData = handler.readDataToEndOfFile()
            return String(data: outputData, encoding: .utf8) ?? ""
        }, status: process.terminationStatus)
    }

    private func terminationStatus(of process: Process) -> Int32 {
        process.launch()
        process.waitUntilExit()
        return process.terminationStatus
    }
}
