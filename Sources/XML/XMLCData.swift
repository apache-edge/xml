import Foundation

/// Represents a CDATA section in an XML document
public final class XMLCData: XMLNode {
    /// The text content
    public let text: String
    
    /// The parent element of this node
    public internal(set) weak var parent: XMLElement?
    
    /// Creates a new CDATA section
    /// - Parameter text: The text content
    public init(text: String) {
        self.text = text
    }
    
    /// The XML string representation of this CDATA section
    public var xmlString: String {
        return "<![CDATA[\(text)]]>"
    }
}