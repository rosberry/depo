//
// Copyright (c) 2020 ___FULLUSERNAME___. All rights reserved.
//

import Foundation
import ArgumentParser

struct BuildPods: ParsableCommand {

    enum CustomError: LocalizedError {
        case badCarPodFileURL(path: String)
        case badPodInstall
        case badPodfile(path: String)
        case badPodBuild(pods: [Pod])
    }

    static let configuration: CommandConfiguration = .init(abstract: "Install and build pods")

    @Option(name: .shortAndLong, default: AppConfiguration.initialDirectoryPath, help: "Directory with CarPodfile")
    var projectPath: String


    @Option(name: .shortAndLong, default: AppConfiguration.buildPodShellScriptFilePath, help: "Path to build_pod shell script")
    var buildPodShellScriptPath: String

    func run() throws {
        let pods = try readPods(configFilePath: projectPath + "/\(AppConfiguration.configFileName)")
        podInitIfNeeded(from: FileManager.default.currentDirectoryPath, at: projectPath)
        try createPodfile(with: pods, platformVersion: 13.1)
        try podInstall(from: FileManager.default.currentDirectoryPath, at: projectPath)
        try build(pods: pods, from: FileManager.default.currentDirectoryPath, at: projectPath + "/Pods")
    }

    private func readPods(configFilePath: String) throws -> [Pod] {
        guard let data = NSData(contentsOfFile: configFilePath) as Data? else {
            throw CustomError.badCarPodFileURL(path: configFilePath)
        }
        return try JSONDecoder().decode([Pod].self, from: data)
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

    private func createPodfile(with pods: [Pod], platformVersion: Double) throws {
        let content = PodFile(pods: pods, platformVersion: platformVersion).description.data(using: .utf8)
        let path = projectPath + "/Podfile"
        if !FileManager.default.createFile(atPath: path, contents: content) {
            throw CustomError.badPodfile(path: path)
        }
    }

    private func podInstall(from currentPath: String, at path: String) throws {
        FileManager.default.changeCurrentDirectoryPath(path)
        let status = shell("pod", "install")
        FileManager.default.changeCurrentDirectoryPath(currentPath)
        if status != 0 {
            throw CustomError.badPodInstall
        }
    }

    private func build(pods: [Pod], from currentPath: String, at path: String) throws {
        FileManager.default.changeCurrentDirectoryPath(path)
        let failedPods = pods.reduce([Pod]()) { (result, pod) in
            if shell(filePath: buildPodShellScriptPath, arguments: [pod.name]) != 0 {
                return result + [pod]
            }
            else {
                return result
            }
        }
        FileManager.default.changeCurrentDirectoryPath(currentPath)
        if !failedPods.isEmpty {
            throw CustomError.badPodBuild(pods: failedPods)
        }
    }
}
