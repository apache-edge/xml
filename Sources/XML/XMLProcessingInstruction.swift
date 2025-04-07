import Foundation

/// Represents an XML processing instruction
public final class XMLProcessingInstruction: XMLNode {
    /// The processing instruction target
    public let target: String
    
    /// The processing instruction data
    public let data: String
    
    /// The parent element of this node
    public internal(set) weak var parent: XMLElement?
    
    /// Creates a new processing instruction
    /// - Parameters:
    ///   - target: The target
    ///   - data: The data
    public init(target: String, data: String) {
        self.target = target
        self.data = data
    }
    
    /// The XML string representation of this processing instruction
    public var xmlString: String {
        return "<?\(target) \(data)?>"
    }
}