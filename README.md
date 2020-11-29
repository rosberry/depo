# Depo :station:
The dependency managers wrapper. 

+ Use Carthage, Pods and SwiftPackages in single project easily.
+ Manage Cartfile, Podfile and Package.swift by single **Depofile** file. 
+ Update and install Carthage, Pods and Swift Packages by single command
+ Build Pods into actual **frameworks** (like Carthage did) and just add them into your `xcodeproj`. No more `xcworkspacecs` and other weird-pods stuff

## Requirements

- Swift 5.3+

## Installation
### Makefile
```
git clone git@github.com:rosberry/Depo.git
cd Depo
make
```

## Example
```
depo init <PATH_TO_CARTFILE> <PATH_TO_PODFILE> <PATH_TO_PACKAGE_SWIFT>
depo install
```

## Documentation
```
$ depo -h
OVERVIEW: Main

USAGE: depo <subcommand>

OPTIONS:
  --version               Show the version.
  -h, --help              Show help information.

SUBCOMMANDS:
  init
  update
  install (default)
  build
  pod
  carthage
  spm

  See 'depo help <subcommand>' for detailed help.
```

## About

<img src="https://github.com/rosberry/Foundation/blob/master/Assets/full_logo.png?raw=true" height="100" />

This project is owned and maintained by [Rosberry](http://rosberry.com). We build mobile apps for users worldwide 🌏.

Check out our [open source projects](https://github.com/rosberry), read [our blog](https://medium.com/@Rosberry) or give us a high-five on 🐦 [@rosberryapps](http://twitter.com/RosberryApps).

## License

This project is available under the MIT license. See the LICENSE file for more info.
