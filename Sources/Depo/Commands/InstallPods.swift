//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import ArgumentParser
import Yams

final class InstallPods: ParsableCommand {

    enum Error: LocalizedError {
        case badPodInit
        case badPodInstall
        case badPodfile(path: String)
        case badPodBuild(pods: [Pod])
        case badPodMerge(pods: [Pod])
    }

    static let configuration: CommandConfiguration = .init(commandName: "pod-install")

    @OptionGroup()
    private(set) var options: Options

    private let podsPrefix: String = "Pods"
    private let buildFrameworkShellScriptPath: String = AppConfiguration.buildPodShellScriptFilePath
    private let mergePodShellScriptPath: String = AppConfiguration.mergePodShellScriptFilePath
    private let moveBuiltPodShellScriptPath: String = AppConfiguration.moveBuiltPodShellFilePath
    private let podFileName: String = AppConfiguration.podFileName
    private let podsDirectoryName: String = AppConfiguration.podsDirectoryName
    private let podsOutputDirectoryName: String = AppConfiguration.podsOutputDirectoryName

    private let pods: [Pod]?
    private let shell: Shell = .init()

    init() {
        self.pods = nil
    }

    init(pods: [Pod]) {
        self.pods = pods
    }

    func run() throws {
        let pods = try self.pods ?? Depofile(decoder: options.depoFileType.decoder).pods
        let podFilePath = "./\(podFileName)"
        let podsProjectPath = "./\(podsDirectoryName)"

        try podInitIfNeeded(podFilePath: podFilePath)
        try createPodfile(at: podFilePath, with: pods, platformVersion: 9.0)
        try podInstall()
        try build(pods: pods, at: podsProjectPath)
        try proceedAllPods(at: podsProjectPath, to: podsOutputDirectoryName)
    }

    private func podInitIfNeeded(podFilePath: String) throws {
        guard !FileManager.default.fileExists(atPath: podFilePath) else {
            return
        }
        if !shell("pod", "init") {
            throw Error.badPodInit
        }
    }

    private func createPodfile(at podFilePath: String, with pods: [Pod], platformVersion: Double) throws {
        let content = PodFile(pods: pods, platformVersion: platformVersion).description.data(using: .utf8)
        if !FileManager.default.createFile(atPath: podFilePath, contents: content) {
            throw Error.badPodfile(path: podFilePath)
        }
    }

    private func podInstall() throws {
        if !shell("pod", "install") {
            throw Error.badPodInstall
        }
    }

    private func build(pods: [Pod], at path: String) throws {
        let currentPath = FileManager.default.currentDirectoryPath
        FileManager.default.changeCurrentDirectoryPath(path)
        let failedPods = pods.reduce([Pod]()) { (result, pod) in
            if !shell(filePath: buildFrameworkShellScriptPath, arguments: [pod.name]) {
                return result + [pod]
            }
            else {
                return result
            }
        }
        FileManager.default.changeCurrentDirectoryPath(currentPath)
        if !failedPods.isEmpty {
            throw Error.badPodBuild(pods: failedPods)
        }
    }

    private func proceedAllPods(at path: String, to outputPath: String) throws {
        let projectPath = FileManager.default.currentDirectoryPath
        FileManager.default.changeCurrentDirectoryPath(path)
        let failedPods = try allSchemes().reduce([Pod]()) { (result, schema) in
            let (pod, settings) = schema
            do {
                try proceed(pod: pod, with: settings, to: "\(projectPath)/\(outputPath)")
                return result
            }
            catch {
                return result + [pod]
            }
        }
        FileManager.default.changeCurrentDirectoryPath(projectPath)
        if !failedPods.isEmpty {
            throw Error.badPodMerge(pods: failedPods)
        }
    }

    private func proceed(pod: Pod, with settings: BuildSettings, to outputPath: String) throws {
        switch kind(for: pod, with: settings) {
        case .common:
            if !shell(filePath: mergePodShellScriptPath, arguments: [pod.name, settings.productName, outputPath, "../build"]) {
                throw Error.badPodMerge(pods: [pod])
            }
        case .builtFramework:
            if !shell(filePath: moveBuiltPodShellScriptPath, arguments: [pod.name]) {
                throw Error.badPodMerge(pods: [pod])
            }
        case .unknown:
            break
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

    private func kind(for pod: Pod, with buildSettings: BuildSettings) -> Pod.Kind {
        if buildSettings.codesigningFolderPath?.lastPathComponent.contains(".framework") == false {
            return .builtFramework
        }
        else {
            return .common
        }
    }
}
