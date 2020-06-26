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

    @Option(name: .shortAndLong, default: AppConfiguration.buildPodShellScriptFilePath, help: "Path to build_pod shell script")
    var buildPodShellScriptPath: String

    func run() throws {
        let path = FileManager.default.currentDirectoryPath
        let pods = try readPods(configFilePath: path + "/\(AppConfiguration.configFileName)")
        let podFilePath = path + "/Podfile"
        let podsProjectPath = path + "/Pods"

        try podInitIfNeeded(podFilePath: podFilePath)
        try createPodfile(at: podFilePath, with: pods, platformVersion: 13.1)
        try podInstall()
        try build(pods: pods, at: podsProjectPath)
    }

    private func readPods(configFilePath: String) throws -> [Pod] {
        guard let data = NSData(contentsOfFile: configFilePath) as Data? else {
            throw CustomError.badCarPodFileURL(path: configFilePath)
        }
        return try JSONDecoder().decode([Pod].self, from: data)
    }

    private func podInitIfNeeded(podFilePath: String) throws {
        guard !FileManager.default.fileExists(atPath: podFilePath) else {
            return
        }
        let status = shell("pod", "init")
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

    private func podInstall() throws {
        if shell("pod", "install") != 0 {
            throw CustomError.badPodInstall
        }
    }

    private func build(pods: [Pod], at path: String) throws {
        let currentPath = FileManager.default.currentDirectoryPath
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
