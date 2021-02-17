//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import Yams
import Files

public final class PodManager: ProgressObservable, HasAllCommands {

    public typealias Package = Pod
    public typealias BuildResult = PackageOutput<Package>

    public typealias FailedContext = (Swift.Error, Pod)

    public enum State {
        case installing
        case updating
        case building
        case processing
        case creatingPodfile(path: String)
        case buildingPod(Pod, MergePackage.FrameworkKind, buildPath: String)
        case processingPod(Pod)
        case movingPod(Pod, outputPath: String)
        case making(MergePackage.FrameworkKind, Pod, outputPath: String)
        case skipProceed(target: String)
        case doneBuilding(Pod)
        case buildingFailed(Pod)
        case doneProcessing(Pod)
        case processingFailed(Pod)
        case shell(state: Shell.State)
    }

    public enum Error: Swift.Error {
        case badPodfile(path: String)
        case badPodBuild(contexts: [FailedContext])
        case badPodMerge(contexts: [FailedContext])
        case noTargetsToBuild
    }

    private enum CodingKeys: String, CodingKey {
        case options
        case pods
    }

    public let outputPath: String = AppConfiguration.Path.Relative.podsOutputDirectory
    private let podsInternalTargetsPrefix: String = AppConfiguration.podsInternalTargetsPrefix
    private let podFileName: String = AppConfiguration.Name.podfile
    private let podsDirectoryName: String = AppConfiguration.Name.podsDirectory
    private let podsOutputDirectoryName: String = AppConfiguration.Path.Relative.podsOutputDirectory
    private let productExtensions: [String] = ["framework", "bundle", "xcframework"]

    private let shell: Shell
    private let xcodebuild: XcodeBuild
    private let podShellCommand: PodShellCommand
    private let frameworkKind: MergePackage.FrameworkKind
    private let podArguments: String?
    private lazy var mergePackage: MergePackage = MergePackage(shell: shell)
    private var observer: ((State) -> Void)?

    public init(podCommandPath: String,
                frameworkKind: MergePackage.FrameworkKind,
                podArguments: String?) {
        let shell = Shell()
        self.shell = shell
        self.xcodebuild = XcodeBuild(shell: shell)
        self.podShellCommand = .init(commandPath: podCommandPath, shell: shell)
        self.frameworkKind = frameworkKind
        self.podArguments = podArguments
        self.shell.subscribe { [weak self] state in
            self?.observer?(.shell(state: state))
        }
    }

    public func subscribe(_ observer: @escaping (State) -> Void) -> Self {
        self.observer = observer
        return self
    }

    public func install(packages: [Package]) throws -> [BuildResult] {
        observer?(.installing)
        let podFilePath = "./\(podFileName)"

        try podInitIfNeeded(podFilePath: podFilePath)
        try createPodfile(at: podFilePath, with: packages, buildSettings: .init(xcodebuild: xcodebuild))
        try podShellCommand.install(args: podArguments.mapOrEmpty(keyPath: \.words))
        return try build(packages: packages)
    }

    public func update(packages: [Package]) throws -> [BuildResult] {
        let podFilePath = "./\(podFileName)"

        observer?(.updating)
        try createPodfile(at: podFilePath, with: packages, buildSettings: .init(xcodebuild: xcodebuild))
        try podShellCommand.update(args: podArguments.mapOrEmpty(keyPath: \.words))
        return try build(packages: packages)
    }

    public func build(packages: [Package]) throws -> [BuildResult] {
        let podsProjectPath = "./\(podsDirectoryName)"

        observer?(.building)
        try build(pods: packages, frameworkKind: frameworkKind, at: podsProjectPath)
        observer?(.processing)
        try proceedAllPods(at: podsProjectPath, frameworkKind: frameworkKind, to: podsOutputDirectoryName)
        return []
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
            observer?(.buildingPod(pod, frameworkKind, buildPath: path))
            do {
                try build(pod: pod, ofKind: frameworkKind)
                observer?(.doneBuilding(pod))
                return result
            }
            catch {
                observer?(.buildingFailed(pod))
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
        let proceedErrors: [FailedContext] = try allBuildContexts().compactMap { context in
            let (pod, settings) = context
            observer?(.processingPod(pod))
            do {
                try proceed(pod: pod, with: settings, to: "\(projectPath)/\(outputPath)", frameworkKind: frameworkKind)
                observer?(.doneProcessing(pod))
                return nil
            }
            catch {
                observer?(.processingFailed(pod))
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
            observer?(.making(frameworkKind, pod, outputPath: outputPath))
            try mergePackage.make(frameworkKind, pod: pod, settings: settings, outputPath: outputPath, buildDir: "../build")
        case .builtFramework:
            observer?(.movingPod(pod, outputPath: outputPath))
            try move(builtPod: pod, outputPath: outputPath)
        case .unknown:
            break
        }
    }

    private func move(builtPod pod: Pod, outputPath: String) throws -> [String] {
        let outputFolder = try Folder(path: outputPath)
        return try Folder(path: pod.name).allSubfolders.compactMap { subfolder -> String? in
            guard isProduct(subfolder) else {
                return nil
            }
            try? outputFolder.subfolder(named: subfolder.name).delete()
            try subfolder.copy(to: outputFolder)
            return subfolder.path
        }
    }

    private func isProduct(_ folder: Folder) -> Bool {
        productExtensions.contains(with: folder.extension ?? "", at: \.self)
    }

    private func allBuildContexts() throws -> [(Pod, BuildSettings)] {
        let project = try xcodebuild.listProject()
        return try project.targets.compactMap { targetName in
            guard !targetName.starts(with: podsInternalTargetsPrefix) else {
                return nil
            }
            let settings = try BuildSettings(target: targetName, xcodebuild: xcodebuild)
            guard shouldProceedPod(with: settings) else {
                observer?(.skipProceed(target: targetName))
                return nil
            }
            return (Pod(name: targetName, versionConstraint: nil), settings)
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
    private func build(pod: Pod, ofKind frameworkKind: MergePackage.FrameworkKind) throws -> [String] {
        switch frameworkKind {
        case .fatFramework:
            return try buildFatFramework(pod: pod)
        case .xcframework:
            return try buildForXCFramework(pod: pod)
        }
    }

    @discardableResult
    private func buildFatFramework(pod: Pod) throws -> [String] {
        [try xcodebuild(settings: .device(target: pod.name)),
         try xcodebuild(settings: .simulator(target: pod.name))]
    }

    @discardableResult
    private func buildForXCFramework(pod: Pod) throws -> [String] {
        [try xcodebuild.buildForDistribution(settings: .device(target: pod.name)),
         try xcodebuild.buildForDistribution(settings: .simulator(target: pod.name))]
    }

    private func shouldProceedPod(with settings: BuildSettings) -> Bool {
        settings.productType == nil || settings.productType == .framework
    }
}
