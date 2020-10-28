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

    private let podsInternalTargetsPrefix: String = AppConfiguration.podsInternalTargetsPrefix
    private let buildPodShellScriptPath: String = AppConfiguration.buildPodShellScriptFilePath
    private let mergePodShellScriptPath: String = AppConfiguration.mergePodShellScriptFilePath
    private let moveBuiltPodShellScriptPath: String = AppConfiguration.moveBuiltPodShellFilePath
    private let podFileName: String = AppConfiguration.podFileName
    private let podsDirectoryName: String = AppConfiguration.podsDirectoryName

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
        try proceedAllPods(at: podsProjectPath)
    }

    private func podInitIfNeeded(podFilePath: String) throws {
        guard !FileManager.default.fileExists(atPath: podFilePath) else {
            return
        }
        if shell("pod", "init") != 0 {
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
        if shell("pod", "install") != 0 {
            throw Error.badPodInstall
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
            throw Error.badPodBuild(pods: failedPods)
        }
    }

    private func proceedAllPods(at path: String) throws {
        let currentPath = FileManager.default.currentDirectoryPath
        FileManager.default.changeCurrentDirectoryPath(path)
        let failedPods = try allSchemes().reduce([Pod]()) { (result, schema) in
            let (pod, settings) = schema
            do {
                try proceed(pod: pod, with: settings)
                return result
            }
            catch {
                return result + [pod]
            }
        }
        FileManager.default.changeCurrentDirectoryPath(currentPath)
        if !failedPods.isEmpty {
            throw Error.badPodMerge(pods: failedPods)
        }
    }

    private func proceed(pod: Pod, with settings: BuildSettings) throws {
        switch kind(for: pod, with: settings) {
        case .common:
            let status: Int32 = shell(filePath: mergePodShellScriptPath, arguments: [pod.name, settings.productName])
            if status != 0 {
                throw Error.badPodMerge(pods: [pod])
            }
        case .builtFramework:
            let status: Int32 = shell(filePath: moveBuiltPodShellScriptPath, arguments: [pod.name])
            if status != 0 {
                throw Error.badPodMerge(pods: [pod])
            }
        case .unknown:
            break
        }
    }

    private func allSchemes() throws -> [(Pod, BuildSettings)] {
        let project = try XcodeProject(shell: shell)
        return try project.targets.compactMap { targetName in
            guard !targetName.starts(with: podsInternalTargetsPrefix) else {
                return nil
            }
            return (Pod(name: targetName, versionConstraint: nil),
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
