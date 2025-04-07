#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

/// A comprehensive Swift 6 XML library for parsing, querying, traversing, and mutating XML documents.
///
/// The XML library provides a complete toolkit for working with XML in Swift, offering an
/// intuitive API that makes common XML operations simple while supporting advanced features.
///
/// ## Overview
///
/// The library is structured around a protocol-based design with `XMLNode` as the base protocol
/// and specific implementations for different node types:
///
/// - ``XMLElement``: Represents an XML element with attributes and child nodes
/// - ``XMLText``: Represents text content within an element
/// - ``XMLComment``: Represents XML comments
/// - ``XMLCData``: Represents CDATA sections
/// - ``XMLProcessingInstruction``: Represents XML processing instructions
/// - ``XMLDocument``: Represents a complete XML document
///
/// ## Common Tasks
///
/// ### Parsing XML
///
/// ```swift
/// // Parse from string
/// let document = try XML.parse(string: xmlString)
///
/// // Parse from file
/// let document = try XML.parse(contentsOfFile: "document.xml")
/// ```
///
/// ### Querying XML
///
/// ```swift
/// // Find all book elements
/// let books = document.root.query("book")
///
/// // Find books with a specific attribute
/// let fictionBooks = document.root.query("book[@category='fiction']")
///
/// // Find elements by path
/// let titles = document.root.query("book/title")
/// ```
///
/// ### Building XML
///
/// ```swift
/// let builder = XML.build(root: "library")
///     .element(name: "book", attributes: ["category": "fiction"])
///         .element(name: "title", content: "The Hitchhiker's Guide to the Galaxy")
///         .parent()
///         .element(name: "author", content: "Douglas Adams")
///         .parent()
///     .parent()
///
/// let document = builder.xmlDocument
/// ```
///
/// ### Modifying XML
///
/// ```swift
/// // Add a new element
/// let newElement = XML.element(name: "chapter", content: "Introduction")
/// book.addChild(newElement)
///
/// // Change content
/// element.setContent("New content")
///
/// // Update an attribute
/// element.setAttribute("status", value: "published")
/// ```
///
public enum XML {
    /// Creates a new XML document from a string.
    ///
    /// This method parses an XML string into a structured document object model.
    ///
    /// - Parameter string: The XML string to parse. This should be a well-formed XML document.
    /// - Returns: A new ``XMLDocument`` instance containing the parsed document structure.
    /// - Throws: ``XMLParseError`` if the XML is malformed or contains invalid content.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let xmlString = """
    /// <?xml version="1.0" encoding="UTF-8"?>
    /// <library>
    ///   <book category="fiction">
    ///     <title>The Hitchhiker's Guide to the Galaxy</title>
    ///     <author>Douglas Adams</author>
    ///   </book>
    /// </library>
    /// """
    ///
    /// do {
    ///     let document = try XML.parse(string: xmlString)
    ///     let title = document.root.query("book/title").first?.textContent
    ///     print("Title: \(title ?? "Not found")")
    /// } catch {
    ///     print("Failed to parse XML: \(error)")
    /// }
    /// ```
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