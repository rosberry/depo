//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import Yams

public final class PodManager: ProgressObservable {

    public typealias FailedContext = (Swift.Error, Pod)

    public enum State {
        case installing
        case updating
        case building
        case processing
        case creatingPodfile(path: String)
        case buildingPod(Pod)
        case processingPod(Pod)
        case shell(state: Shell.State)
    }

    public enum Error: Swift.Error {
        case badPodfile(path: String)
        case badPodBuild(contexts: [FailedContext])
        case badPodMerge(contexts: [FailedContext])
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

    private let shell: Shell = .init()
    private let podShellCommand: PodShellCommand
    private lazy var buildPodScript: BuildPodScript = .init(shell: shell)
    private lazy var mergePackageScript: MergePackageScript = .init(shell: shell)
    private lazy var moveBuiltPodScript: MoveBuiltPodScript = .init(shell: shell)
    private var observer: ((State) -> Void)?

    public init(depofile: Depofile, podCommandPath: String) {
        self.pods = depofile.pods
        self.podShellCommand = .init(commandPath: podCommandPath, shell: shell)
        self.shell.subscribe { [weak self] state in
            self?.observer?(.shell(state: state))
        }
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
        try createPodfile(at: podFilePath, with: pods, buildSettings: .init(shell: shell))
        try podShellCommand.install()
        observer?(.building)
        try build(pods: pods, at: podsProjectPath)
        try proceedAllPods(at: podsProjectPath, to: podsOutputDirectoryName)
    }

    public func update() throws {
        observer?(.updating)
        let podFilePath = "./\(podFileName)"
        let podsProjectPath = "./\(podsDirectoryName)"

        try createPodfile(at: podFilePath, with: pods, buildSettings: .init(shell: shell))
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

    private func createPodfile(at podFilePath: String, with pods: [Pod], buildSettings: BuildSettings) throws {
        observer?(.creatingPodfile(path: podFilePath))
        let podfile = PodFile(buildSettings: buildSettings, pods: pods)
        let content = podfile.description.data(using: .utf8)
        if !FileManager.default.createFile(atPath: podFilePath, contents: content) {
            throw Error.badPodfile(path: podFilePath)
        }
    }

    private func build(pods: [Pod], at path: String) throws {
        let currentPath = FileManager.default.currentDirectoryPath
        FileManager.default.changeCurrentDirectoryPath(path)
        let buildErrors = pods.reduce([FailedContext]()) { (result, pod) in
            observer?(.buildingPod(pod))
            do {
                try buildPodScript(pod: pod)
                return result
            }
            catch {
                return result + [(error, pod)]
            }
        }
        FileManager.default.changeCurrentDirectoryPath(currentPath)
        if !buildErrors.isEmpty {
            throw Error.badPodBuild(contexts: buildErrors)
        }
    }

    private func proceedAllPods(at path: String, to outputPath: String) throws {
        let projectPath = FileManager.default.currentDirectoryPath
        FileManager.default.changeCurrentDirectoryPath(path)
        let proceedErrors: [FailedContext] = try allSchemes().compactMap { schema in
            let (pod, settings) = schema
            observer?(.processingPod(pod))
            do {
                try proceed(pod: pod, with: settings, to: "\(projectPath)/\(outputPath)")
                return nil
            }
            catch {
                return (error, pod)
            }
        }
        FileManager.default.changeCurrentDirectoryPath(projectPath)
        if !proceedErrors.isEmpty {
            throw Error.badPodMerge(contexts: proceedErrors)
        }
    }

    private func proceed(pod: Pod, with settings: BuildSettings, to outputPath: String) throws {
        switch kind(for: pod, with: settings) {
        case .common:
            try mergePackageScript(pod: pod, settings: settings, outputPath: outputPath, buildDir: "../build")
        case .builtFramework:
            try moveBuiltPodScript(pod: pod)
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
