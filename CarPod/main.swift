//
//  main.swift
//  CarPod
//
//  Created by Владислав Жаворонков on 6/23/20.
//  Copyright © 2020 Владислав Жаворонков. All rights reserved.
//

import Foundation
import Commandant

let commands = CommandRegistry<Error>()
commands.register(BuildPodsCommand(projectURL: AppConfiguration.initialDirectoryURL,
                                   configFileName: AppConfiguration.configFileName,
                                   buildPodShellScriptURL: AppConfiguration.buildPodShellScriptFile))

print(commands.run(command: "build", arguments: []))
