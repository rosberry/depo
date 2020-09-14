//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import ArgumentParser

struct Options: ParsableArguments {

    @Flag(help: "CarPodfile's extension") var carpodFileType: DataDecoder.Kind = .yaml
}
