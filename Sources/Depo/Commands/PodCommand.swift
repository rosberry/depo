//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import ArgumentParser
import Yams

final class PodCommand {

    enum Error: LocalizedError {
        case badPodfile(path: String)
        case badPodBuild(pods: [Pod])
        case badPodMerge(pods: [Pod])
    }

    private enum CodingKeys: String, CodingKey {
        case options
        case pods
    }

    static let configuration: CommandConfiguration = .init(commandName: "pod-install")

    private let podsInternalTargetsPrefix: String = AppConfiguration.podsInternalTargetsPrefix
    private let podFileName: String = AppConfiguration.podFileName
    private let podsDirectoryName: String = AppConfiguration.podsDirectoryName
    private let podsOutputDirectoryName: String = AppConfiguration.podsOutputDirectoryName

    private let pods: [Pod]

    private let shell: Shell = .init()
    private lazy var podShellCommand: PodShellCommand = .init(shell: shell)
    private lazy var buildPodScript: BuildPodScript = .init(shell: shell)
    private lazy var mergePackageScript: MergePackageScript = .init(shell: shell)
    private lazy var moveBuiltPodScript: MoveBuiltPodScript = .init(shell: shell)

    init(pods: [Pod]) {
        self.pods = pods
    }

    func install() throws {
        let podFilePath = "./\(podFileName)"
        let podsProjectPath = "./\(podsDirectoryName)"

        try podInitIfNeeded(podFilePath: podFilePath)
        try createPodfile(at: podFilePath, with: pods, platformVersion: 9.0)
        try podShellCommand.install()
        try build(pods: pods, at: podsProjectPath)
        try proceedAllPods(at: podsProjectPath, to: podsOutputDirectoryName)
    }

    private func podInitIfNeeded(podFilePath: String) throws {
        guard !FileManager.default.fileExists(atPath: podFilePath) else {
            return
        }
        try podShellCommand.initialize()
    }

    private func createPodfile(at podFilePath: String, with pods: [Pod], platformVersion: Double) throws {
        let content = PodFile(pods: pods, platformVersion: platformVersion).description.data(using: .utf8)
        if !FileManager.default.createFile(atPath: podFilePath, contents: content) {
            throw Error.badPodfile(path: podFilePath)
        }
    }

    private func build(pods: [Pod], at path: String) throws {
        let currentPath = FileManager.default.currentDirectoryPath
        FileManager.default.changeCurrentDirectoryPath(path)
        let failedPods = pods.reduce([Pod]()) { (result, pod) in
            !buildPodScript(pod: pod) ? result + [pod] : result
        }
        FileManager.default.changeCurrentDirectoryPath(currentPath)
        if !failedPods.isEmpty {
            throw Error.badPodBuild(pods: failedPods)
        }
    }

    private func proceedAllPods(at path: String, to outputPath: String) throws {
        let projectPath = FileManager.default.currentDirectoryPath
        FileManager.default.changeCurrentDirectoryPath(path)
        let failedPods: [Pod] = try allSchemes().compactMap { schema in
            let (pod, settings) = schema
            let ifProceedFailed = (try? proceed(pod: pod, with: settings, to: "\(projectPath)/\(outputPath)")) == nil
            return ifProceedFailed ? pod : nil
        }
        FileManager.default.changeCurrentDirectoryPath(projectPath)
        if !failedPods.isEmpty {
            throw Error.badPodMerge(pods: failedPods)
        }
    }

    private func proceed(pod: Pod, with settings: BuildSettings, to outputPath: String) throws {
        switch kind(for: pod, with: settings) {
        case .common:
            if !mergePackageScript(pod: pod, settings: settings, outputPath: outputPath, buildDir: "../build") {
                throw Error.badPodMerge(pods: [pod])
            }
        case .builtFramework:
            if !moveBuiltPodScript(pod: pod) {
                throw Error.badPodMerge(pods: [pod])
            }
        case .unknown:
            break
        }
    }

    private func allSchemes() throws -> [(Pod, BuildSettings)] {
        try (try XcodeProject(shell: shell).targets).compactMap { targetName in
            guard !targetName.starts(with: podsInternalTargetsPrefix) else {
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
