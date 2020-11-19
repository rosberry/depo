import Foundation

/// Anything that can be parsed from a Scanner.
public protocol Scannable {
	/// Attempts to parse an instance of the receiver from the given scanner.
	///
	/// If parsing fails, the scanner will be left at the first invalid
	/// character (with any partially valid input already consumed).
	static func from(_ scanner: Scanner) -> Result<Self, ScannableError>
}

extension Scanner {
    /// Returns the current line being scanned.
    internal var currentLine: String {
        // Force Foundation types, so we don't have to use Swift's annoying
        // string indexing.
        let nsString = string as NSString
        let scanRange: NSRange = NSRange(location: scanLocation, length: 0)
        let lineRange: NSRange = nsString.lineRange(for: scanRange)

        return nsString.substring(with: lineRange)
    }
}
