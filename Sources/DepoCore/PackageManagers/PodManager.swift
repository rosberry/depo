//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import Yams

public final class PodManager: ProgressObservable {

    public enum State {

        case installing
        case updating
        case building
        case processing
        case creatingPodfile(path: String)
        case buildingPod(Pod)
        case processingPod(Pod)
    }

    public enum Error: LocalizedError {
        case badPodfile(path: String)
        case badPodBuild(pods: [Pod])
        case badPodMerge(pods: [Pod])
    }

    private enum CodingKeys: String, CodingKey {
        case options
        case pods
    }

    private let podsInternalTargetsPrefix: String = AppConfiguration.podsInternalTargetsPrefix
    private let podFileName: String = AppConfiguration.Name.podfile
    private let podsDirectoryName: String = AppConfiguration.Name.podsDirectory
    private let podsOutputDirectoryName: String = AppConfiguration.Path.Relative.podsOutputDirectory

    private let pods: [Pod]

    private let shell: Shell = Shell().subscribe { state in
        print(state)
    }
    private lazy var podShellCommand: PodShellCommand = .init(shell: shell)
    private lazy var buildPodScript: BuildPodScript = .init(shell: shell)
    private lazy var mergePackageScript: MergePackageScript = .init(shell: shell)
    private lazy var moveBuiltPodScript: MoveBuiltPodScript = .init(shell: shell)
    private var observer: ((State) -> Void)?

    public init(depofile: Depofile) {
        self.pods = depofile.pods
    }

    public func subscribe(_ observer: @escaping (State) -> Void) -> Self {
        self.observer = observer
        return self
    }

    public func install() throws {
        observer?(.installing)
        let podFilePath = "./\(podFileName)"
        let podsProjectPath = "./\(podsDirectoryName)"

        try podInitIfNeeded(podFilePath: podFilePath)
        try createPodfile(at: podFilePath, with: pods)
        try podShellCommand.install()
        observer?(.building)
        try build(pods: pods, at: podsProjectPath)
        try proceedAllPods(at: podsProjectPath, to: podsOutputDirectoryName)
    }

    public func update() throws {
        observer?(.updating)
        let podFilePath = "./\(podFileName)"
        let podsProjectPath = "./\(podsDirectoryName)"

        try createPodfile(at: podFilePath, with: pods)
        try podShellCommand.update()
        observer?(.building)
        try build(pods: pods, at: podsProjectPath)
        #warning("proceeding all pods seems redundant")
        try proceedAllPods(at: podsProjectPath, to: podsOutputDirectoryName)
    }

    public func build() throws {
        observer?(.building)
        let podsProjectPath = "./\(podsDirectoryName)"

        try build(pods: pods, at: podsProjectPath)
        try proceedAllPods(at: podsProjectPath, to: podsOutputDirectoryName)
    }

    private func podInitIfNeeded(podFilePath: String) throws {
        guard !FileManager.default.fileExists(atPath: podFilePath) else {
            return
        }
        try podShellCommand.initialize()
    }

    private func createPodfile(at podFilePath: String, with pods: [Pod]) throws {
        observer?(.creatingPodfile(path: podFilePath))
        let podfile = PodFile(buildSettings: try .init(), pods: pods)
        let content = podfile.description.data(using: .utf8)
        if !FileManager.default.createFile(atPath: podFilePath, contents: content) {
            throw Error.badPodfile(path: podFilePath)
        }
    }

    private func build(pods: [Pod], at path: String) throws {
        let currentPath = FileManager.default.currentDirectoryPath
        FileManager.default.changeCurrentDirectoryPath(path)
        let failedPods = pods.reduce([Pod]()) { (result, pod) in
            observer?(.buildingPod(pod))
            return !buildPodScript(pod: pod) ? result + [pod] : result
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
            observer?(.processingPod(pod))
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
