import Foundation

/// Uniquely identifies a Binary Spec's resolved URL and its description
public struct BinaryURL: CustomStringConvertible {
    /// A Resolved URL
    public let url: URL

    /// A custom description
    public let resolvedDescription: String

    public var description: String {
        return resolvedDescription
    }

    init(url: URL, resolvedDescription: String) {
        self.url = url
        self.resolvedDescription = resolvedDescription
    }
}

/// Uniquely identifies a project that can be used as a dependency.
public enum Dependency: Hashable {
    /// A repository hosted on GitHub.com or GitHub Enterprise.
    case gitHub(String)

    /// An arbitrary Git repository.
    case git(URL?)

    /// A binary-only framework
    case binary(BinaryURL)

    /// The unique, user-visible name for this project.
    public var name: String {
        switch self {
        case let .gitHub(identifier):
            return identifier

        case let .git(url):
            return url?.absoluteString ?? ""

        case let .binary(url):
            return url.name
        }
    }
}

extension Dependency {
    fileprivate init(gitURL: URL?) {
        let githubHostIdentifier = "github.com"
        let urlString = gitURL?.absoluteString ?? ""

        if urlString.contains(githubHostIdentifier) {
            let gitbubHostScanner = Scanner(string: urlString)

            gitbubHostScanner.scanUpTo(githubHostIdentifier, into: nil)
            gitbubHostScanner.scanString(githubHostIdentifier, into: nil)

            // find an SCP or URL path separator
            let separatorFound = (gitbubHostScanner.scanString("/", into: nil) || gitbubHostScanner.scanString(":",
                                                                                                               into: nil)) && !gitbubHostScanner.isAtEnd

            let startOfOwnerAndNameSubstring = gitbubHostScanner.scanLocation

            if separatorFound && startOfOwnerAndNameSubstring <= urlString.utf16.count {
                let ownerAndNameSubstring = String(urlString[
                        urlString.index(urlString.startIndex, offsetBy: startOfOwnerAndNameSubstring)..<urlString.endIndex
                        ])

                self = Dependency.git(gitURL)
                return
            }
        }

        self = Dependency.git(gitURL)
    }
}

extension Dependency: Comparable {
    public static func < (_ lhs: Dependency, _ rhs: Dependency) -> Bool {
        return lhs.name.caseInsensitiveCompare(rhs.name) == .orderedAscending
    }
}

extension Dependency: Scannable {
    /// Attempts to parse a Dependency.
    public static func from(_ scanner: Scanner) -> Result<Dependency, ScannableError> {
        return from(scanner, base: nil)
    }

    public static func from(_ scanner: Scanner, base: URL? = nil) -> Result<Dependency, ScannableError> {
        let parser: (String) -> Result<Dependency, ScannableError>

        if scanner.scanString("github", into: nil) {
            parser = { repoIdentifier in
                return .success(self.gitHub(repoIdentifier))
            }
        }
        else if scanner.scanString("git", into: nil) {
            parser = { urlString in

                return .success(Dependency(gitURL: URL(string: urlString)))
            }
        }
        else if scanner.scanString("binary", into: nil) {
            parser = { urlString in
                if let url = URL(string: urlString) {
                    if url.scheme == "https" || url.scheme == "file" {
                        return .success(self.binary(BinaryURL(url: url, resolvedDescription: url.description)))
                    }
                    else if url.scheme == nil {
                        // This can use URL.init(fileURLWithPath:isDirectory:relativeTo:) once we can target 10.11+
                        let absoluteURL = url.relativePath
                                .withCString { URL(fileURLWithFileSystemRepresentation: $0, isDirectory: false, relativeTo: base) }
                                .standardizedFileURL
                        return .success(self.binary(BinaryURL(url: absoluteURL, resolvedDescription: url.absoluteString)))
                    }
                    else {
                        return .failure(ScannableError(message: "non-https, non-file URL found for dependency type `binary`",
                                                       currentLine: scanner.currentLine))
                    }
                }
                else {
                    return .failure(ScannableError(message: "invalid URL found for dependency type `binary`",
                                                   currentLine: scanner.currentLine))
                }
            }
        }
        else {
            return .failure(ScannableError(message: "unexpected dependency type", currentLine: scanner.currentLine))
        }

        if !scanner.scanString("\"", into: nil) {
            return .failure(ScannableError(message: "expected string after dependency type", currentLine: scanner.currentLine))
        }

        guard let address = scanner.scanUpToString("\""),
              scanner.scanString("\"") != nil else {
            return .failure(ScannableError(message: "empty or unterminated string after dependency type", currentLine: scanner.currentLine))
        }
        return parser(address)
    }
}

extension Dependency: CustomStringConvertible {
    public var description: String {
        switch self {
        case let .gitHub(identifier):
            return "github \"\(identifier)\""

        case let .git(url):
            return "git \"\(url?.absoluteString ?? "")\""

        case let .binary(binary):
            return "binary \"\(binary)\""
        }
    }
}

extension BinaryURL: Equatable {
    public static func == (_ lhs: BinaryURL, _ rhs: BinaryURL) -> Bool {
        return lhs.description == rhs.description
    }
}

extension BinaryURL: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(description)
    }
}

extension BinaryURL {
    /// The unique, user-visible name for this project.
    public var name: String {
        url.absoluteString
    }
}
