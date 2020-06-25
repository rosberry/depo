//
// Copyright (c) 2020 ___FULLUSERNAME___. All rights reserved.
//

import Foundation
import Commandant

struct BuildPodsCommand: CommandProtocol {

    enum CustomError: LocalizedError {
        case badCarPodFileURL
    }

    let verb: String = "build"
    let function: String = "Test function"
    let projectURL: URL
    let configFileURL: URL
    let podFileURL: URL

    init(projectURL: URL, configFileName: String) {
        self.projectURL = projectURL
        self.configFileURL = projectURL.appendingPathComponent(configFileName)
        self.podFileURL = projectURL.appendingPathComponent("Podfile")
    }

    func run(_ options: NoOptions<Error>) -> Result<(), Error> {
        .init {
            guard let data = NSData(contentsOfFile: configFileURL.absoluteString) as Data? else {
                throw CustomError.badCarPodFileURL
            }
            podInitIfNeeded(from: FileManager.default.currentDirectoryPath, at: projectURL.absoluteString)
            let value = try JSONDecoder().decode([Pod].self, from: data)
            let podFile = PodFile(pods: value, platformVersion: 13.1)
            try podFile.description.write(to: URL(string: "file://" + podFileURL.absoluteString)!, atomically: false, encoding: .utf8)
            podInstall(from: FileManager.default.currentDirectoryPath, at: projectURL.absoluteString)
        }
    }

    private func podInitIfNeeded(from currentPath: String, at path: String) {
        guard !FileManager.default.fileExists(atPath: podFileURL.absoluteString) else {
            return
        }
        FileManager.default.changeCurrentDirectoryPath(path)
        shell("pod", "init")
        FileManager.default.changeCurrentDirectoryPath(currentPath)
    }

    private func podInstall(from currentPath: String, at path: String) {
        FileManager.default.changeCurrentDirectoryPath(path)
        shell("pod", "install")
        FileManager.default.changeCurrentDirectoryPath(currentPath)
    }
}
