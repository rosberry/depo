//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import ArgumentParser

struct Options: ParsableArguments {

    @Flag(help: "Depofile's extension") var depoFileType: DataDecoder.Kind = DataDecoder.Kind.defaultValue
}
