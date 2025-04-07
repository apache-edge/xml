import Foundation

/// Swift XML library for parsing, querying, traversing, and mutating XML documents
public enum XML {
    /// Creates a new XML document from a string
    /// - Parameter string: The XML string to parse
    /// - Returns: The parsed XML document
    /// - Throws: XMLParseError if parsing fails
    public static func parse(string: String) throws -> XMLDocument {
        return try XMLDocument.parse(string: string)
    }
    
    /// Creates a new XML document from a file
    /// - Parameter url: The URL of the file to parse
    /// - Returns: The parsed XML document
    /// - Throws: XMLParseError if parsing fails
    public static func parse(contentsOf url: URL) throws -> XMLDocument {
        return try XMLDocument.parse(contentsOf: url)
    }
    
    /// Creates a new XML document from a file path
    /// - Parameter path: The path to the file to parse
    /// - Returns: The parsed XML document
    /// - Throws: XMLParseError if parsing fails
    public static func parse(contentsOfFile path: String) throws -> XMLDocument {
        return try XMLDocument.parse(contentsOfFile: path)
    }
    
    /// Creates a new XML builder with a root element
    /// - Parameters:
    ///   - rootName: The name of the root element
    ///   - attributes: Optional attributes for the root element
    ///   - version: The XML version, defaults to "1.0"
    ///   - encoding: The XML encoding, defaults to "UTF-8"
    /// - Returns: An XML builder
    public static func build(root rootName: String, attributes: [String: String] = [:], version: String = "1.0", encoding: String = "UTF-8") -> XMLBuilder {
        return XMLBuilder(rootName: rootName, attributes: attributes, version: version, encoding: encoding)
    }
    
    /// Creates a new element with the given name, attributes, and content
    /// - Parameters:
    ///   - name: The element name
    ///   - attributes: Optional attributes for the element
    ///   - content: Optional text content for the element
    /// - Returns: A new XML element
    public static func element(name: String, attributes: [String: String] = [:], content: String? = nil) -> XMLElement {
        return XMLElement(name: name, attributes: attributes, content: content)
    }
    
    /// Creates a new text node
    /// - Parameter text: The text content
    /// - Returns: A new XML text node
    public static func text(_ text: String) -> XMLText {
        return XMLText(text: text)
    }
    
    /// Creates a new comment
    /// - Parameter text: The comment text
    /// - Returns: A new XML comment
    public static func comment(_ text: String) -> XMLComment {
        return XMLComment(text: text)
    }
    
    /// Creates a new CDATA section
    /// - Parameter text: The CDATA content
    /// - Returns: A new XML CDATA section
    public static func cdata(_ text: String) -> XMLCData {
        return XMLCData(text: text)
    }
    
    /// Creates a new processing instruction
    /// - Parameters:
    ///   - target: The processing instruction target
    ///   - data: The processing instruction data
    /// - Returns: A new XML processing instruction
    public static func processingInstruction(target: String, data: String) -> XMLProcessingInstruction {
        return XMLProcessingInstruction(target: target, data: data)
    }
}