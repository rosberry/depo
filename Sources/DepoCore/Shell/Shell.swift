//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

public final class Shell: Codable {

    public struct IO {
        public let stdOut: String
        public let stdErr: String
        public let stdIn: String
        public let status: Int32

        fileprivate init(stdOut: String, stdErr: String, stdIn: String, status: Int32) {
            self.stdOut = stdOut
            self.stdErr = stdErr
            self.stdIn = stdIn
            self.status = status
        }
    }

    public init() {}

    public func callAsFunction(_ args: [String]) -> Bool {
        let process = Process()
        process.launchPath = "/usr/bin/env"
        process.arguments = args
        return terminationStatus(of: process) == 0
    }

    public func callAsFunction(_ args: String...) -> Bool {
        callAsFunction(args)
    }

    public func callAsFunction(filePath: String, arguments: [String] = []) -> Bool {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: filePath)
        process.arguments = arguments
        return terminationStatus(of: process) == 0
    }

    public func callAsFunction(_ args: [String]) throws -> IO {
        let process = Process()
        process.launchPath = "/usr/bin/env"
        process.arguments = args
        return try output(of: process)
    }

    public func callAsFunction(_ args: String...) throws -> IO {
        try callAsFunction(args)
    }

    public func callAsFunction(filePath: String, arguments: [String] = []) throws -> IO {
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
