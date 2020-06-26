//
//  main.swift
//  CarPod
//
//  Created by Владислав Жаворонков on 6/23/20.
//  Copyright © 2020 Владислав Жаворонков. All rights reserved.
//

import Foundation
import ArgumentParser

struct CarPod: ParsableCommand {
     static let configuration: CommandConfiguration = .init(abstract: "Dooooooo",
                                                            version: "0.0",
                                                            subcommands: [BuildPods.self],
                                                            defaultSubcommand: BuildPods.self)
}

CarPod.main(["build-pods"])
