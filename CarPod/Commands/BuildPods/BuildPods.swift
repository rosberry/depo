//
// Copyright (c) 2020 ___FULLUSERNAME___. All rights reserved.
//

import Foundation
import ArgumentParser

struct BuildPods: ParsableCommand {

    enum CustomError: LocalizedError {
        case badCarPodFileURL(path: String)
        case badPodInit
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
        let podFilePath = projectPath + "/Podfile"
        let podsProjectPath = projectPath + "/Pods"

        try podInitIfNeeded(podFilePath: podFilePath, from: FileManager.default.currentDirectoryPath, at: projectPath)
        try createPodfile(at: podFilePath, with: pods, platformVersion: 13.1)
        try podInstall(from: FileManager.default.currentDirectoryPath, at: projectPath)
        try build(pods: pods, from: FileManager.default.currentDirectoryPath, at: podsProjectPath)
    }

    private func readPods(configFilePath: String) throws -> [Pod] {
        guard let data = NSData(contentsOfFile: configFilePath) as Data? else {
            throw CustomError.badCarPodFileURL(path: configFilePath)
        }
        return try JSONDecoder().decode([Pod].self, from: data)
    }

    private func podInitIfNeeded(podFilePath: String, from currentPath: String, at path: String) throws {
        guard !FileManager.default.fileExists(atPath: podFilePath) else {
            return
        }
        FileManager.default.changeCurrentDirectoryPath(path)
        let status = shell("pod", "init")
        FileManager.default.changeCurrentDirectoryPath(currentPath)
        if status != 0 {
            throw CustomError.badPodInit
        }
    }

    private func createPodfile(at podFilePath: String, with pods: [Pod], platformVersion: Double) throws {
        let content = PodFile(pods: pods, platformVersion: platformVersion).description.data(using: .utf8)
        if !FileManager.default.createFile(atPath: podFilePath, contents: content) {
            throw CustomError.badPodfile(path: podFilePath)
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
