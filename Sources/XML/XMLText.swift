import Foundation

/// Represents a text node in an XML document
public final class XMLText: XMLNode {
    /// The text content
    public let text: String
    
    /// The parent element of this node
    public internal(set) weak var parent: XMLElement?
    
    /// Creates a new text node
    /// - Parameter text: The text content
    public init(text: String) {
        self.text = text
    }
    
    /// The XML string representation of this text node
    public var xmlString: String {
        return XMLText.escapeText(text)
    }
    
    /// Escapes text for XML
    /// - Parameter text: The text to escape
    /// - Returns: The escaped text
    internal static func escapeText(_ text: String) -> String {
        return text
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
    }
}