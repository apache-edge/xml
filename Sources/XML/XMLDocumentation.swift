/// XML Documentation Extension
///
/// This file contains documentation-only extensions to enhance the DocC experience.

import Foundation

/// XML is a comprehensive Swift library for parsing, processing, and generating XML documents.
///
/// ## Topics
///
/// ### Getting Started
///
/// - <doc:GettingStarted>
/// - ``XML``
/// - ``XMLDocument``
///
/// ### Core Components
///
/// - ``XMLNode``
/// - ``XMLElement``
/// - ``XMLText``
/// - ``XMLComment``
/// - ``XMLCData``
/// - ``XMLProcessingInstruction``
///
/// ### Working with XML
///
/// - ``XMLQuery``
/// - ``XMLBuilder``
/// - ``XMLParseError``
///
/// ### Articles
///
/// - <doc:Parsing>
/// - <doc:Querying>
/// - <doc:Building>
/// - <doc:Serialization>

/// # Getting Started
///
/// Learn how to use the XML library to work with XML documents in Swift.
///
/// ## Overview
///
/// The XML library provides a comprehensive set of tools for working with XML in Swift.
/// This article introduces the basic concepts and demonstrates how to perform common XML tasks.
///
/// ## Installation
///
/// Add the XML library to your Swift package using the Swift Package Manager:
///
/// ```swift
/// dependencies: [
///     .package(url: "https://github.com/apache-edge/xml.git", from: "1.0.0")
/// ]
/// ```
///
/// Then add the dependency to your target:
///
/// ```swift
/// .target(
///     name: "YourTarget",
///     dependencies: ["XML"]
/// )
/// ```
///
/// ## Basic Usage
///
/// Here's a quick example that demonstrates parsing, querying, and modifying an XML document:
///
/// ```swift
/// import XML
///
/// // Parse XML from a string
/// let xmlString = """
/// <library>
///   <book category="fiction">
///     <title>The Hitchhiker's Guide to the Galaxy</title>
///     <author>Douglas Adams</author>
///     <year>1979</year>
///   </book>
/// </library>
/// """
///
/// // Parse the XML
/// let document = try XML.parse(string: xmlString)
///
/// // Query elements
/// let titles = document.root.query("book/title")
/// for title in titles {
///     print("Title: \(title.textContent)")
/// }
///
/// // Add new content
/// let newBook = XML.element(name: "book", attributes: ["category": "science"])
/// newBook.addChild(XML.element(name: "title", content: "A Brief History of Time"))
/// newBook.addChild(XML.element(name: "author", content: "Stephen Hawking"))
/// newBook.addChild(XML.element(name: "year", content: "1988"))
///
/// document.root.addChild(newBook)
///
/// // Serialize back to XML
/// let updatedXML = document.xmlStringFormatted(pretty: true)
/// print(updatedXML)
/// ```
///
/// ## Next Steps
///
/// Explore more detailed topics to learn about the library's capabilities:
///
/// - <doc:Parsing>: Learn how to parse XML from strings and files
/// - <doc:Querying>: Discover how to query XML using XPath-like syntax
/// - <doc:Building>: See how to build XML documents programmatically
/// - <doc:Serialization>: Learn about serializing XML to strings and files
@_documentation(visibility: public)
enum GettingStarted {}

/// # Parsing XML
///
/// Learn how to parse XML from strings and files.
///
/// ## Parsing from Strings
///
/// The most common way to parse XML is from a string:
///
/// ```swift
/// import XML
///
/// let xmlString = """
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
///     print("Parsed successfully! Root element: \(document.root.name)")
/// } catch let error as XMLParseError {
///     print("Parsing error: \(error)")
/// } catch {
///     print("Unexpected error: \(error)")
/// }
/// ```
///
/// ## Parsing from Files
///
/// You can also parse XML directly from files:
///
/// ```swift
/// do {
///     // Parse from a file path
///     let document = try XML.parse(contentsOfFile: "/path/to/file.xml")
///     
///     // Or parse from a URL
///     let url = URL(fileURLWithPath: "/path/to/file.xml")
///     let documentFromURL = try XML.parse(contentsOf: url)
/// } catch {
///     print("Failed to parse file: \(error)")
/// }
/// ```
///
/// ## Handling Parse Errors
///
/// The parser throws specific error types for different parsing issues:
///
/// ```swift
/// do {
///     let document = try XML.parse(string: xmlString)
///     // Process document
/// } catch let error as XMLParseError {
///     switch error {
///     case .malformedXML(let message):
///         print("Malformed XML: \(message)")
///     case .invalidStructure(let message):
///         print("Invalid structure: \(message)")
///     case .unexpectedEnd(let message):
///         print("Unexpected end: \(message)")
///     default:
///         print("Other parsing error: \(error)")
///     }
/// }
/// ```
///
/// ## Accessing the Parsed Document
///
/// After parsing, you can access the document structure:
///
/// ```swift
/// let document = try XML.parse(string: xmlString)
///
/// // Access the root element
/// let root = document.root
/// print("Root element: \(root.name)")
///
/// // Access XML declaration information
/// print("XML version: \(document.version)")
/// print("XML encoding: \(document.encoding)")
///
/// // Access root's children
/// for child in root.childElements {
///     print("Child element: \(child.name)")
/// }
/// ```
@_documentation(visibility: public)
enum Parsing {}

/// # Querying XML
///
/// Learn how to query XML documents using XPath-like syntax.
///
/// ## Basic Queries
///
/// The XML library provides an XPath-like query system for finding elements:
///
/// ```swift
/// // Query all book elements that are direct children of the root
/// let books = document.root.query("book")
///
/// // Query all title elements that are children of book elements
/// let titles = document.root.query("book/title")
///
/// // Query the first matching element
/// if let firstTitle = document.root.queryFirst("book/title") {
///     print("First title: \(firstTitle.textContent)")
/// }
/// ```
///
/// ## Filtering by Attributes
///
/// You can filter elements by their attributes:
///
/// ```swift
/// // Find books in the fiction category
/// let fictionBooks = document.root.query("book[@category='fiction']")
///
/// // Find books that have a bestseller attribute (regardless of value)
/// let bestsellerBooks = document.root.query("book[@bestseller]")
///
/// // Combine multiple attribute filters
/// let fictionBestsellers = document.root.query("book[@category='fiction'][@bestseller='true']")
/// ```
///
/// ## Special Selectors
///
/// The query system supports several special selectors:
///
/// ```swift
/// // Wildcard: find all immediate children
/// let allChildren = element.query("*")
///
/// // Parent navigation: find parent of the title elements
/// let bookParents = document.root.query("book/title/..")
///
/// // Index: find the first book element
/// let firstBook = document.root.query("book[1]")
///
/// // Text content: find elements with specific text
/// let specificTitles = document.root.query("title[text()='The Hitchhiker's Guide to the Galaxy']")
/// ```
///
/// ## Chaining Queries
///
/// You can chain queries for more complex selections:
///
/// ```swift
/// // Find all fiction books
/// let fictionBooks = document.root.query("book[@category='fiction']")
///
/// // Then find all their titles
/// let fictionTitles = fictionBooks.flatMap { $0.query("title") }
///
/// // Combine with Swift filtering
/// let longTitles = fictionTitles.filter { $0.textContent.count > 20 }
/// ```
@_documentation(visibility: public)
enum Querying {}

/// # Building XML
///
/// Learn how to build XML documents programmatically.
///
/// ## Using the Builder Pattern
///
/// The `XMLBuilder` class provides a fluent interface for building XML documents:
///
/// ```swift
/// let builder = XML.build(root: "library")
///     .documentComment("Library catalog")
///     .element(name: "book", attributes: ["category": "fiction"])
///         .element(name: "title", content: "The Hitchhiker's Guide to the Galaxy")
///         .parent()
///         .element(name: "author", content: "Douglas Adams")
///         .parent()
///         .element(name: "year", content: "1979")
///         .parent()
///     .parent()
///     .element(name: "book", attributes: ["category": "non-fiction"])
///         .element(name: "title", content: "A Brief History of Time")
///         .parent()
///         .element(name: "author", content: "Stephen Hawking")
///         .parent()
///         .element(name: "year", content: "1988")
///         .parent()
///     .parent()
///
/// let document = builder.xmlDocument
/// ```
///
/// ## Building with Closures
///
/// You can also use closures for a more Swifty approach:
///
/// ```swift
/// let builder = XML.build(root: "library")
///     .element(name: "book", attributes: ["category": "fiction"]) { builder in
///         builder.element(name: "title", content: "The Hitchhiker's Guide to the Galaxy")
///         builder.element(name: "author", content: "Douglas Adams")
///         builder.element(name: "year", content: "1979")
///     }
///     .element(name: "book", attributes: ["category": "non-fiction"]) { builder in
///         builder.element(name: "title", content: "A Brief History of Time")
///         builder.element(name: "author", content: "Stephen Hawking")
///         builder.element(name: "year", content: "1988")
///     }
///
/// let document = builder.xmlDocument
/// ```
///
/// ## Building Manually
///
/// You can also build XML manually using the direct API:
///
/// ```swift
/// // Create the root element
/// let root = XMLElement(name: "library")
///
/// // Create the first book
/// let book1 = XMLElement(name: "book", attributes: ["category": "fiction"])
/// book1.addChild(XMLElement(name: "title", content: "The Hitchhiker's Guide to the Galaxy"))
/// book1.addChild(XMLElement(name: "author", content: "Douglas Adams"))
/// book1.addChild(XMLElement(name: "year", content: "1979"))
///
/// // Create the second book
/// let book2 = XMLElement(name: "book", attributes: ["category": "non-fiction"])
/// book2.addChild(XMLElement(name: "title", content: "A Brief History of Time"))
/// book2.addChild(XMLElement(name: "author", content: "Stephen Hawking"))
/// book2.addChild(XMLElement(name: "year", content: "1988"))
///
/// // Add books to the root
/// root.addChild(book1)
/// root.addChild(book2)
///
/// // Create the document
/// let document = XMLDocument(root: root)
/// ```
///
/// ## Adding Special Node Types
///
/// You can add different types of nodes to your XML:
///
/// ```swift
/// // Add a comment
/// element.addChild(XML.comment("This is a comment"))
///
/// // Add a CDATA section
/// element.addChild(XML.cdata("<data>Raw content that shouldn't be parsed</data>"))
///
/// // Add a processing instruction
/// element.addChild(XML.processingInstruction(target: "xml-stylesheet", data: "type=\"text/xsl\" href=\"style.xsl\""))
/// ```
@_documentation(visibility: public)
enum Building {}

/// # Serialization
///
/// Learn how to convert XML documents to strings and files.
///
/// ## Basic Serialization
///
/// You can easily convert any XML document or element to a string:
///
/// ```swift
/// // Serialize a document
/// let xmlString = document.xmlString
///
/// // Serialize an element
/// let elementString = element.xmlString
/// ```
///
/// ## Pretty Formatting
///
/// For better readability, you can use pretty formatting with indentation:
///
/// ```swift
/// // Get a pretty-formatted version of the XML
/// let prettyXML = document.xmlStringFormatted(pretty: true)
/// ```
///
/// ## Writing to Files
///
/// XML documents can be written directly to files:
///
/// ```swift
/// // Write to a file path
/// try document.write(toFile: "/path/to/output.xml")
///
/// // Write with pretty formatting
/// try document.write(toFile: "/path/to/output.xml", pretty: true)
///
/// // Write to a URL
/// let url = URL(fileURLWithPath: "/path/to/output.xml")
/// try document.write(to: url, pretty: true)
/// ```
///
/// ## Working with Special Characters
///
/// The library automatically handles XML escaping for special characters:
///
/// ```swift
/// // Text with special characters
/// let element = XML.element(name: "description", content: "Text with <tags> & special \"characters\"")
///
/// // The output will have properly escaped characters
/// print(element.xmlString)
/// // Outputs: <description>Text with &lt;tags&gt; &amp; special "characters"</description>
/// ```
///
/// ## Round-Trip Processing
///
/// You can parse XML, modify it, and serialize it back:
///
/// ```swift
/// // Parse original XML
/// let document = try XML.parse(string: originalXml)
///
/// // Make modifications
/// if let element = document.root.queryFirst("some/element") {
///     element.setContent("Updated content")
/// }
///
/// // Serialize back to string
/// let updatedXml = document.xmlString
/// ```
@_documentation(visibility: public)
enum Serialization {}