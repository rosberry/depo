# Depo :station:
The dependency managers wrapper. 

+ Use Carthage, Pods and SwiftPackages in single project easily.
+ Manage Cartfile, Podfile and Package.swift by single **Depofile** file. 
+ Update and install Carthage, Pods and Swift Packages by single command
+ Build Pods into actual **frameworks** (like Carthage did) and just add them into your `xcodeproj`. No more `xcworkspacecs` and other weird-pods stuff

## Requirements

- Swift 5.3+

## Installation
### Homebrew
```
brew install rosberry/tap/depo
```

### Makefile
```
git clone git@github.com:rosberry/Depo.git
cd Depo
make
```

## Usage
### Example
```
depo init <PATH_TO_CARTFILE> <PATH_TO_PODFILE> <PATH_TO_PACKAGE_SWIFT>
depo install
```

### Depofile
Depofile is a file, which compose Cartfile, Podfile and Package.swift. For each file there is a section: carts, pods and swiftPackages. Each section has items, and for example items from 'swiftPackages' section should have `name` `url` and `version` -- as they have it in original Package.swift. For more information look at [Depofile Example](./DepofileExample.yaml)


## Documentation
```
$ depo -h
OVERVIEW: Main

USAGE: depo <subcommand>

OPTIONS:
  --version               Show the version.
  -h, --help              Show help information.

SUBCOMMANDS:
  init                    create Depofile
  update                  run update for all package managers
  install (default)       run install for all package managers
  build                   run build for all package managers
  pod                     Pod wrapper
  carthage                Carthage wrapper
  spm                     SPM wrapper
  example                 prints example of Depofile

  See 'depo help <subcommand>' for detailed help.
```

## About

<img src="https://github.com/rosberry/Foundation/blob/master/Assets/full_logo.png?raw=true" height="100" />

This project is owned and maintained by [Rosberry](http://rosberry.com). We build mobile apps for users worldwide 🌏.

Check out our [open source projects](https://github.com/rosberry), read [our blog](https://medium.com/@Rosberry) or give us a high-five on 🐦 [@rosberryapps](http://twitter.com/RosberryApps).

## License

This project is available under the MIT license. See the LICENSE file for more info.
