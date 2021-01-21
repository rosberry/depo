//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import Yams
import Files

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
        case movingPod(from: String, toFolder: String)
        case shell(state: Shell.State)
        case merge(state: MergePackage.State)
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
    private let productExtensions: [String] = ["framework", "bundle", "xcframework"]

    private let pods: [Pod]

    private let shell: Shell = .init()
    private let podShellCommand: PodShellCommand
    private let frameworkKind: MergePackage.FrameworkKind
    private let cacheBuilds: Bool
    private let podArguments: String?
    private lazy var mergePackage: MergePackage = MergePackage(shell: shell).subscribe { [weak self] state in
        self?.observer?(.merge(state: state))
    }
    private var observer: ((State) -> Void)?

    public init(depofile: Depofile,
                podCommandPath: String,
                frameworkKind: MergePackage.FrameworkKind,
                cacheBuilds: Bool,
                podArguments: String?) {
        self.pods = depofile.pods
        self.podShellCommand = .init(commandPath: podCommandPath, shell: shell)
        self.frameworkKind = frameworkKind
        self.cacheBuilds = cacheBuilds
        self.podArguments = podArguments
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
        try build(pods: pods, frameworkKind: frameworkKind, at: podsProjectPath)
        try proceedAllPods(at: podsProjectPath, frameworkKind: frameworkKind, to: podsOutputDirectoryName)
    }

    public func update() throws {
        observer?(.updating)
        let podFilePath = "./\(podFileName)"
        let podsProjectPath = "./\(podsDirectoryName)"

        try createPodfile(at: podFilePath, with: pods, buildSettings: .init(shell: shell))
        try podShellCommand.update()
        observer?(.building)
        try build(pods: pods, frameworkKind: frameworkKind, at: podsProjectPath)
        #warning("proceeding all pods seems redundant")
        try proceedAllPods(at: podsProjectPath, frameworkKind: frameworkKind, to: podsOutputDirectoryName)
    }

    public func build() throws {
        observer?(.building)
        let podsProjectPath = "./\(podsDirectoryName)"

        try build(pods: pods, frameworkKind: frameworkKind, at: podsProjectPath)
        try proceedAllPods(at: podsProjectPath, frameworkKind: frameworkKind, to: podsOutputDirectoryName)
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

    private func build(pods: [Pod], frameworkKind: MergePackage.FrameworkKind, at path: String) throws {
        let currentPath = FileManager.default.currentDirectoryPath
        FileManager.default.changeCurrentDirectoryPath(path)
        let buildErrors = pods.reduce([FailedContext]()) { result, pod in
            observer?(.buildingPod(pod))
            do {
                try build(pod: pod, ofKind: frameworkKind)
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

    private func proceedAllPods(at path: String, frameworkKind: MergePackage.FrameworkKind, to outputPath: String) throws {
        let projectPath = FileManager.default.currentDirectoryPath
        FileManager.default.changeCurrentDirectoryPath(path)
        let proceedErrors: [FailedContext] = try allSchemes().compactMap { schema in
            let (pod, settings) = schema
            observer?(.processingPod(pod))
            do {
                try proceed(pod: pod, with: settings, to: "\(projectPath)/\(outputPath)", frameworkKind: frameworkKind)
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

    private func proceed(pod: Pod, with settings: BuildSettings, to outputPath: String, frameworkKind: MergePackage.FrameworkKind) throws {
        switch kind(for: pod, with: settings) {
        case .common:
            try mergePackage.make(frameworkKind, pod: pod, settings: settings, outputPath: outputPath, buildDir: "../build")
        case .builtFramework:
            try move(builtPod: pod)
        case .unknown:
            break
        }
    }

    private func move(builtPod pod: Pod) throws {
        let outputFolder = try Folder(path: "Build/iOS")
        let podBuildProductsDirectory = try Folder(path: pod.name)
        for subFolder in podBuildProductsDirectory.allSubfolders where isProduct(subFolder) {
            observer?(.movingPod(from: subFolder.path, toFolder: outputFolder.path))
            try? outputFolder.subfolder(named: subFolder.name).delete()
            try subFolder.copy(to: outputFolder)
        }
    }

    private func isProduct(_ folder: Folder) -> Bool {
        productExtensions.contains(with: folder.extension ?? "", at: \.self)
    }

    private func allSchemes() throws -> [(Pod, BuildSettings)] {
        let project = try XcodeProjectList(shell: shell)
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

    @discardableResult
    private func build(pod: Pod, ofKind frameworkKind: MergePackage.FrameworkKind) throws -> [Shell.IO] {
        switch frameworkKind {
        case .fatFramework:
            return try buildFatFramework(pod: pod)
        case .xcframework:
            return try buildForXCFramework(pod: pod)
        }
    }

    @discardableResult
    private func buildFatFramework(pod: Pod) throws -> [Shell.IO] {
        let xcodebuild = XcodeBuild(shell: shell)
        return [try xcodebuild(.device(target: pod.name)),
                try xcodebuild(.simulator(target: pod.name))]
    }

    @discardableResult
    private func buildForXCFramework(pod: Pod) throws -> [Shell.IO] {
        let xcodebuild = XcodeBuild(shell: shell)
        return [try xcodebuild.buildForDistribution(.device(target: pod.name)),
                try xcodebuild.buildForDistribution(.simulator(target: pod.name))]
    }
}
