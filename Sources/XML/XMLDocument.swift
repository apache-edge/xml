#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

/// Represents a complete XML document with a root element, declaration, and optional metadata.
///
/// `XMLDocument` is the top-level container for XML content, managing the root element and
/// document-level constructs like XML declarations, processing instructions, and comments.
///
/// ## Creating Documents
///
/// You can create documents by parsing XML strings or files, or by programmatically
/// constructing them:
///
/// ```swift
/// // Parse from string
/// let document = try XML.parse(string: xmlString)
///
/// // Parse from file
/// let document = try XML.parse(contentsOfFile: "document.xml")
///
/// // Create programmatically
/// let root = XMLElement(name: "root")
/// let document = XMLDocument(root: root)
/// ```
///
/// ## Document Properties
///
/// A document has several key properties:
///
/// - A root element that contains all document content
/// - XML version and encoding information
/// - Optional declaration, processing instructions, and comments
///
/// ## Accessing and Modifying Content
///
/// Most document operations involve working with the root element:
///
/// ```swift
/// // Access the root element
/// let rootElement = document.root
///
/// // Query elements in the document
/// let elements = document.root.query("book/title")
///
/// // Add content to the document
/// document.root.addChild(XMLElement(name: "section"))
/// ```
///
/// ## Serialization
///
/// Documents can be serialized to XML strings with optional pretty formatting:
///
/// ```swift
/// // Get XML as a compact string
/// let xmlString = document.xmlString
///
/// // Get XML with pretty formatting
/// let prettyXml = document.xmlStringFormatted(pretty: true)
///
/// // Write to file
/// try document.write(toFile: "output.xml", pretty: true)
/// ```
public final class XMLDocument {
    /// The XML version
    public let version: String
    
    /// The XML encoding
    public let encoding: String
    
    /// The root element of the document
    public let root: XMLElement
    
    /// The XML declaration
    public var declaration: XMLProcessingInstruction?
    
    /// Any processing instructions before the root element
    public var processingInstructions: [XMLProcessingInstruction]
    
    /// Any comments before the root element
    public var comments: [XMLComment]
    
    /// Creates a new XML document
    /// - Parameters:
    ///   - root: The root element
    ///   - version: The XML version, defaults to "1.0"
    ///   - encoding: The XML encoding, defaults to "UTF-8"
    public init(root: XMLElement, version: String = "1.0", encoding: String = "UTF-8") {
        self.root = root
        self.version = version
        self.encoding = encoding
        self.processingInstructions = []
        self.comments = []
        
        self.declaration = XMLProcessingInstruction(
            target: "xml",
            data: "version=\"\(version)\" encoding=\"\(encoding)\""
        )
    }
    
    /// Adds a processing instruction to the document
    /// - Parameter instruction: The processing instruction to add
    /// - Returns: Self for method chaining
    @discardableResult
    public func addProcessingInstruction(_ instruction: XMLProcessingInstruction) -> Self {
        processingInstructions.append(instruction)
        return self
    }
    
    /// Adds a comment to the document
    /// - Parameter comment: The comment to add
    /// - Returns: Self for method chaining
    @discardableResult
    public func addComment(_ comment: XMLComment) -> Self {
        comments.append(comment)
        return self
    }
    
    /// The XML string representation of this document
    public var xmlString: String {
        xmlStringFormatted(pretty: false)
    }
    
    /// Returns the XML string representation of this document with optional pretty formatting
    /// - Parameter pretty: Whether to format the XML with indentation and line breaks
    /// - Returns: The XML string
    public func xmlStringFormatted(pretty: Bool = false) -> String {
        var result = ""
        
        // Add XML declaration
        if let declaration = declaration {
            result += declaration.xmlString + "\n"
        }
        
        // Add processing instructions
        for instruction in processingInstructions {
            result += instruction.xmlString + "\n"
        }
        
        // Add comments
        for comment in comments {
            result += comment.xmlString + "\n"
        }
        
        // Add root element
        result += pretty ? formatXML(root, level: 0) : root.xmlString
        
        return result
    }
    
    /// Formats an XML node with proper indentation
    /// - Parameters:
    ///   - node: The node to format
    ///   - level: The current indentation level
    /// - Returns: The formatted XML string
    private func formatXML(_ node: XMLNode, level: Int) -> String {
        let indent = String(repeating: "    ", count: level)
        
        if let element = node as? XMLElement {
            var result = "\(indent)<\(element.name)"
            
            // Add attributes
            for (key, value) in element.attributes.sorted(by: { $0.key < $1.key }) {
                let escapedValue = value.replacingOccurrences(of: "\"", with: "&quot;")
                result += " \(key)=\"\(escapedValue)\""
            }
            
            // Check if we have children or content
            if element.children.isEmpty && element.content == nil {
                result += " />\n"
            } else {
                result += ">"
                
                // Check if we have only text content
                let hasNonTextChildren = element.children.contains { !($0 is XMLText) }
                
                if !hasNonTextChildren {
                    // If we only have text, keep it on the same line
                    for child in element.children {
                        result += child.xmlString
                    }
                    result += "</\(element.name)>\n"
                } else {
                    // If we have structured content, format it with indentation
                    result += "\n"
                    
                    for child in element.children {
                        result += formatXML(child, level: level + 1)
                    }
                    
                    result += "\(indent)</\(element.name)>\n"
                }
            }
            
            return result
        } else if let comment = node as? XMLComment {
            return "\(indent)\(comment.xmlString)\n"
        } else if let cdata = node as? XMLCData {
            return "\(indent)\(cdata.xmlString)\n"
        } else if let pi = node as? XMLProcessingInstruction {
            return "\(indent)\(pi.xmlString)\n"
        } else if let text = node as? XMLText {
            // Text nodes don't need indentation
            return text.xmlString
        }
        
        return ""
    }
    
    /// Creates a deep copy of this document
    /// - Returns: A new XMLDocument with copies of all nodes
    public func copy() -> XMLDocument {
        let rootCopy = root.copy()
        let copy = XMLDocument(root: rootCopy, version: version, encoding: encoding)
        
        copy.processingInstructions = processingInstructions.map { 
            XMLProcessingInstruction(target: $0.target, data: $0.data) 
        }
        
        copy.comments = comments.map { 
            XMLComment(text: $0.text) 
        }
        
        return copy
    }
}

// MARK: - Parsing
extension XMLDocument {
    /// Parse XML from a string
    /// - Parameter string: The XML string to parse
    /// - Returns: A new XMLDocument
    /// - Throws: XMLParseError if parsing fails
    public static func parse(string: String) throws -> XMLDocument {
        let parser = XMLParser(string: string)
        return try parser.parse()
    }
    
    /// Parse XML from a file
    /// - Parameter url: The URL of the file to parse
    /// - Returns: A new XMLDocument
    /// - Throws: XMLParseError if parsing fails or the file can't be read
    public static func parse(contentsOf url: URL) throws -> XMLDocument {
        let data = try Data(contentsOf: url)
        guard let string = String(data: data, encoding: .utf8) else {
            throw XMLParseError.invalidData("Could not decode data as UTF-8")
        }
        return try parse(string: string)
    }
    
    /// Parse XML from a file path
    /// - Parameter path: The path to the file to parse
    /// - Returns: A new XMLDocument
    /// - Throws: XMLParseError if parsing fails or the file can't be read
    public static func parse(contentsOfFile path: String) throws -> XMLDocument {
        let url = URL(fileURLWithPath: path)
        return try parse(contentsOf: url)
    }
}

// MARK: - Writing
extension XMLDocument {
    /// Writes the XML to a file
    /// - Parameters:
    ///   - url: The URL to write to
    ///   - pretty: Whether to format the XML with indentation and line breaks
    /// - Throws: Error if writing fails
    public func write(to url: URL, pretty: Bool = false) throws {
        let data = xmlStringFormatted(pretty: pretty).data(using: .utf8)!
        try data.write(to: url)
    }
    
    /// Writes the XML to a file path
    /// - Parameters:
    ///   - path: The path to write to
    ///   - pretty: Whether to format the XML with indentation and line breaks
    /// - Throws: Error if writing fails
    public func write(toFile path: String, pretty: Bool = false) throws {
        let url = URL(fileURLWithPath: path)
        try write(to: url, pretty: pretty)
    }
}