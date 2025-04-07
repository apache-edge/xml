#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

/// Represents an XML comment
public final class XMLComment: XMLNode {
    /// The comment text
    public let text: String
    
    /// The parent element of this node
    public internal(set) weak var parent: XMLElement?
    
    /// Creates a new XML comment
    /// - Parameter text: The comment text
    public init(text: String) {
        self.text = text
    }
    
    /// The XML string representation of this comment
    public var xmlString: String {
        return "<!-- \(text) -->"
    }
}