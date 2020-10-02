//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

final class Shell: Codable {

    struct IO {
        let stdOut: String
        let stdErr: String
        let stdIn: String
        let status: Int32

        fileprivate init(stdOut: String, stdErr: String, stdIn: String, status: Int32) {
            self.stdOut = stdOut
            self.stdErr = stdErr
            self.stdIn = stdIn
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

    func callAsFunction(_ args: String...) throws -> IO {
        let process = Process()
        process.launchPath = "/usr/bin/env"
        process.arguments = args
        return try output(of: process)
    }

    func callAsFunction(filePath: String, arguments: [String] = []) throws -> IO {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: filePath)
        process.arguments = arguments
        return try output(of: process)
    }

    private func output(of process: Process) throws -> IO {
        let stdOutPipe = Pipe()
        let stdErrPipe = Pipe()
        let stdInFileHandle = FileHandle()
        process.standardOutput = stdOutPipe
        process.standardError = stdErrPipe
        process.standardInput = stdInFileHandle
        try process.run()
        process.waitUntilExit()
        let handlersStrings = [stdOutPipe.fileHandleForReading,
                               stdErrPipe.fileHandleForReading,
                               stdInFileHandle].map { handler -> String in
            let outputData = handler.readDataToEndOfFile()
            return String(data: outputData, encoding: .utf8) ?? ""
        }
        return IO(stdOut: handlersStrings[0], stdErr: handlersStrings[1], stdIn: handlersStrings[2], status: process.terminationStatus)
    }

    private func terminationStatus(of process: Process) -> Int32 {
        process.launch()
        process.waitUntilExit()
        return process.terminationStatus
    }
}
