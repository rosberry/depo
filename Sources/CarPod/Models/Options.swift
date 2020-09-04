//
// Copyright © 2020 ___FULLUSERNAME___. All rights reserved.
//

import Foundation
import ArgumentParser

struct Options: ParsableArguments {

    @Option(name: .shortAndLong, help: "CarPodfile's extension") var carpodFileType: DataDecoder.Kind = .yaml
}
