//
// Copyright (c) 2020 ___FULLUSERNAME___. All rights reserved.
//

import Foundation
import ArgumentParser
import Yams

struct InstallPods: ParsableCommand {

    enum CustomError: LocalizedError {
        case badPodInit
        case badPodInstall
        case badPodfile(path: String)
        case badPodBuild(pods: [Pod])
        case badPodMerge(pods: [Pod])
    }

    static let configuration: CommandConfiguration = .init(abstract: "Install and build pods")

    @OptionGroup()
    private(set) var options: Options

    private let podsPrefix: String = "Pods"
    private let buildPodShellScriptPath: String = AppConfiguration.buildPodShellScriptFilePath
    private let mergePodShellScriptPath: String = AppConfiguration.mergePodShellScriptFilePath

    private let pods: [Pod]?
    private let shell: Shell = .init()

    init() {
        self.pods = nil
    }

    init(pods: [Pod]) {
        self.pods = pods
    }

    func run() throws {
        let pods = try self.pods ?? CarPodfile(decoder: options.carpodFileType.decoder).pods
        let path = FileManager.default.currentDirectoryPath
        let podFilePath = path + "/Podfile"
        let podsProjectPath = path + "/Pods"

        try podInitIfNeeded(podFilePath: podFilePath)
        try createPodfile(at: podFilePath, with: pods, platformVersion: 9.0)
        try podInstall()
        try build(pods: pods, at: podsProjectPath)
        try mergeAllPods(at: podsProjectPath)
    }

    private func podInitIfNeeded(podFilePath: String) throws {
        guard !FileManager.default.fileExists(atPath: podFilePath) else {
            return
        }
        if shell("pod", "init") != 0 {
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

    private func mergeAllPods(at path: String) throws {
        let currentPath = FileManager.default.currentDirectoryPath
        FileManager.default.changeCurrentDirectoryPath(path)
        let failedPods = try allSchemes().reduce([Pod]()) { (result, schema) in
            let (pod, settings) = schema
            let status: Int32 = shell(filePath: mergePodShellScriptPath, arguments: [pod.name, settings.productName])
            if status != 0 {
                return result + [pod]
            }
            else {
                return result
            }
        }
        FileManager.default.changeCurrentDirectoryPath(currentPath)
        if !failedPods.isEmpty {
            throw CustomError.badPodMerge(pods: failedPods)
        }
    }

    private func allSchemes() throws -> [(Pod, BuildSettings)] {
        try (try XcodeProject(shell: shell).targets).compactMap { targetName in
            guard !targetName.starts(with: podsPrefix) else {
                return nil
            }
            return (Pod(name: targetName, version: nil),
                    try BuildSettings(targetName: targetName, shell: shell))
        }
    }
}
