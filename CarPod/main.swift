//
//  main.swift
//  CarPod
//
//  Created by Владислав Жаворонков on 6/23/20.
//  Copyright © 2020 Владислав Жаворонков. All rights reserved.
//

import Foundation
import Commandant

let commands = CommandRegistry<CommandantError<Void>>()
commands.register(BuildPodsCommand())

print(commands.run(command: "build", arguments: []))
