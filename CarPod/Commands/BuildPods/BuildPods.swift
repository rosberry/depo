//
// Copyright (c) 2020 ___FULLUSERNAME___. All rights reserved.
//

import Foundation
import ArgumentParser

struct BuildPods: ParsableCommand {

    enum CustomError: LocalizedError {
        case badCarPodFileURL
    }

    static let configuration: CommandConfiguration = .init(abstract: "Install and build pods")

    @Option(name: .shortAndLong, default: AppConfiguration.initialDirectoryPath, help: "Directory with CarPodfile")
    var projectPath: String

    @Option(name: .shortAndLong, default: AppConfiguration.configFileName, help: "Name of CarPodfile")
    var configFileName: String

    @Option(name: .shortAndLong, default: AppConfiguration.buildPodShellScriptFilePath, help: "Path to build_pod shell script")
    var buildPodShellScriptPath: String

    func run() throws {
        let configFilePath = projectPath + "/\(configFileName)"

        guard let data = NSData(contentsOfFile: configFilePath) as Data? else {
            throw CustomError.badCarPodFileURL
        }
        podInitIfNeeded(from: FileManager.default.currentDirectoryPath, at: projectPath)
        let pods = try JSONDecoder().decode([Pod].self, from: data)
        let podFile = PodFile(pods: pods, platformVersion: 13.1)
        try podFile.description.write(to: URL(string: "file://" + projectPath + "/Podfile")!, atomically: false, encoding: .utf8)
        podInstall(from: FileManager.default.currentDirectoryPath, at: projectPath)
        build(pods: pods, from: FileManager.default.currentDirectoryPath, at: projectPath + "/Pods")
    }

    private func podInitIfNeeded(from currentPath: String, at path: String) {
        let podFilePath = projectPath + "/Podfile"
        guard !FileManager.default.fileExists(atPath: podFilePath) else {
            return
        }
        FileManager.default.changeCurrentDirectoryPath(path)
        shell("pod", "init")
        FileManager.default.changeCurrentDirectoryPath(currentPath)
    }

    private func podInstall(from currentPath: String, at path: String) {
        FileManager.default.changeCurrentDirectoryPath(path)
        shell("pod", "install")
        FileManager.default.changeCurrentDirectoryPath(currentPath)
    }

    private func build(pods: [Pod], from currentPath: String, at path: String) {
        FileManager.default.changeCurrentDirectoryPath(path)
        pods.forEach { (pod: Pod) -> Void in
            shell(filePath: buildPodShellScriptPath, arguments: [pod.name])
        }
        FileManager.default.changeCurrentDirectoryPath(currentPath)
    }
}
