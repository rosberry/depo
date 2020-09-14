//
//  main.swift
//  CarPod
//
//  Created by Владислав Жаворонков on 6/23/20.
//  Copyright © 2020 Владислав Жаворонков. All rights reserved.
//

import Foundation
import ArgumentParser

final class Depo: ParsableCommand {
     static let configuration: CommandConfiguration = .init(abstract: "Main",
                                                            version: "0.0",
                                                            subcommands: [Install.self, InstallPods.self, InstallCarthageItems.self],
                                                            defaultSubcommand: Install.self)
}

Depo.main()
