#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

/// Represents an XML element with a name, attributes, and child nodes.
///
/// `XMLElement` is the primary building block of XML documents, modeling elements like
/// `<book title="Example">Content</book>`. Each element can have attributes, text content,
/// and child nodes of various types.
///
/// ## Creating Elements
///
/// You can create elements directly or using the factory methods in the ``XML`` enum:
///
/// ```swift
/// // Create directly
/// let element = XMLElement(name: "book", attributes: ["title": "Example"])
///
/// // Create using the factory method
/// let element = XML.element(name: "book", attributes: ["title": "Example"])
/// ```
///
/// ## Element Attributes
///
/// Attributes can be accessed and modified using subscripts or dedicated methods:
///
/// ```swift
/// // Using dynamic member lookup
/// element.title = "New Title"
/// let title = element.title
///
/// // Using attribute methods
/// element.setAttribute("title", value: "New Title")
/// let title = element.attributes["title"]
/// ```
///
/// ## Child Management
///
/// Elements can have child nodes of different types. The library provides methods
/// to add, remove, and query child nodes:
///
/// ```swift
/// // Add a child element
/// let child = XML.element(name: "chapter")
/// element.addChild(child)
///
/// // Remove a child
/// element.removeChild(child)
///
/// // Add text content
/// element.addChild(XML.text("Content"))
///
/// // Clear all children
/// element.removeAllChildren()
/// ```
///
/// ## Navigation and Querying
///
/// `XMLElement` provides methods for navigating the XML tree and querying elements:
///
/// ```swift
/// // Find all child elements with a specific name
/// let chapters = book.children(where: { $0.name == "chapter" })
///
/// // Find first child with specific criteria
/// let firstChapter = book.firstChild(where: { $0.attributes["number"] == "1" })
///
/// // Find all descendants matching criteria
/// let allParagraphs = book.descendants(where: { $0.name == "paragraph" })
///
/// // Use XPath-like queries
/// let titles = book.query("chapter/title")
/// ```
@dynamicMemberLookup
public final class XMLElement: XMLNode, Hashable {
    /// The name of the element
    public private(set) var name: String
    
    /// The attributes of this element
    public private(set) var attributes: [String: String]
    
    /// The child nodes of this element
    public private(set) var children: [XMLNode]
    
    /// Optional text content of this element
    public private(set) var content: String?
    
    /// The parent element of this node
    public internal(set) weak var parent: XMLElement?
    
    /// Creates a new XML element
    /// - Parameters:
    ///   - name: The name of the element
    ///   - attributes: Optional attributes for the element
    ///   - content: Optional text content for the element
    public init(name: String, attributes: [String: String] = [:], content: String? = nil) {
        self.name = name
        self.attributes = attributes
        self.children = []
        self.content = content
        
        // Add content as a text node if provided
        if let content = content, !content.isEmpty {
            self.children.append(XMLText(text: content))
        }
    }
    
    /// Creates a deep copy of this element
    /// - Returns: A deep copy of this element
    public func copy() -> XMLElement {
        let copy = XMLElement(name: self.name, attributes: self.attributes, content: self.content)
        
        for child in self.children {
            if let element = child as? XMLElement {
                let childCopy = element.copy()
                copy.addChild(childCopy)
            } else if let text = child as? XMLText {
                copy.addChild(XMLText(text: text.text))
            } else if let comment = child as? XMLComment {
                copy.addChild(XMLComment(text: comment.text))
            } else if let cdata = child as? XMLCData {
                copy.addChild(XMLCData(text: cdata.text))
            } else if let processing = child as? XMLProcessingInstruction {
                copy.addChild(XMLProcessingInstruction(target: processing.target, data: processing.data))
            }
        }
        
        return copy
    }
    
    // MARK: - Child Management
    
    /// Adds a child node to this element
    /// - Parameter child: The child node to add
    /// - Returns: Self for method chaining
    @discardableResult
    public func addChild(_ child: XMLNode) -> Self {
        if let element = child as? XMLElement {
            element.parent = self
        }
        children.append(child)
        return self
    }
    
    /// Adds multiple child nodes to this element
    /// - Parameter children: The child nodes to add
    /// - Returns: Self for method chaining
    @discardableResult
    public func addChildren(_ children: [XMLNode]) -> Self {
        for child in children {
            addChild(child)
        }
        return self
    }
    
    /// Removes a child node from this element
    /// - Parameter child: The child element to remove
    /// - Returns: Self for method chaining
    @discardableResult
    public func removeChild(_ child: XMLNode) -> Self {
        children.removeAll { $0 === child }
        return self
    }
    
    /// Removes a child node at the specified index
    /// - Parameter index: The index to remove the child at
    /// - Returns: Self for method chaining
    @discardableResult
    public func removeChild(at index: Int) -> Self {
        guard index >= 0, index < children.count else { return self }
        children.remove(at: index)
        return self
    }
    
    /// Removes all children of this element
    /// - Returns: Self for method chaining
    @discardableResult
    public func removeAllChildren() -> Self {
        children.removeAll()
        return self
    }
    
    /// Sets the text content of this element.
    ///
    /// This method updates the text content of the element by:
    /// 1. Removing any existing text nodes from the children collection
    /// 2. Setting the `content` property
    /// 3. Adding a new ``XMLText`` node as the first child if content is provided
    ///
    /// - Parameter content: The text content to set. Pass `nil` to remove all text content.
    /// - Returns: Self for method chaining.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let element = XML.element(name: "title")
    /// element.setContent("The Swift Programming Language")
    /// print(element.xmlString) // Outputs: <title>The Swift Programming Language</title>
    ///
    /// // Remove content
    /// element.setContent(nil)
    /// print(element.xmlString) // Outputs: <title />
    /// ```
    ///
    /// ## Notes
    ///
    /// - This method preserves non-text child nodes like elements and comments
    /// - Text nodes are inserted as the first child, so they appear before other children
    /// - If you need more control over mixed content, consider using `addChild` with ``XMLText`` directly
    @discardableResult
    public func setContent(_ content: String?) -> Self {
        self.content = content
        
        // Replace any existing text nodes with the new content
        let nonTextChildren = children.filter { !($0 is XMLText) }
        children = nonTextChildren
        
        if let content = content, !content.isEmpty {
            children.insert(XMLText(text: content), at: 0)
        }
        
        return self
    }
    
    /// Sets an attribute on this element
    /// - Parameters:
    ///   - name: The attribute name
    ///   - value: The attribute value
    /// - Returns: Self for method chaining
    @discardableResult
    public func setAttribute(_ name: String, value: String) -> Self {
        attributes[name] = value
        return self
    }
    
    /// Sets multiple attributes on this element
    /// - Parameter attributes: The attributes to set
    /// - Returns: Self for method chaining
    @discardableResult
    public func setAttributes(_ attributes: [String: String]) -> Self {
        for (key, value) in attributes {
            self.attributes[key] = value
        }
        return self
    }
    
    /// Removes an attribute from this element
    /// - Parameter name: The name of the attribute to remove
    /// - Returns: Self for method chaining
    @discardableResult
    public func removeAttribute(_ name: String) -> Self {
        attributes.removeValue(forKey: name)
        return self
    }
    
    /// Renames this element
    /// - Parameter name: The new name for this element
    /// - Returns: Self for method chaining
    @discardableResult
    public func rename(_ name: String) -> Self {
        self.name = name
        return self
    }
    
    // MARK: - Navigation
    
    /// Returns all child elements (not including text nodes, comments, etc.)
    public var childElements: [XMLElement] {
        children.compactMap { $0 as? XMLElement }
    }
    
    /// Returns all text nodes among the direct children
    public var textNodes: [XMLText] {
        children.compactMap { $0 as? XMLText }
    }
    
    /// Returns the combined text content of all direct text children
    public var textContent: String {
        textNodes.map { $0.text }.joined()
    }
    
    /// Returns the first child matching the given predicate
    /// - Parameter predicate: A closure that takes an XMLElement and returns a Bool
    /// - Returns: The first matching child element, or nil if none found
    public func firstChild(where predicate: (XMLElement) -> Bool) -> XMLElement? {
        for child in children {
            if let element = child as? XMLElement, predicate(element) {
                return element
            }
        }
        return nil
    }
    
    /// Returns all children matching the given predicate
    /// - Parameter predicate: A closure that takes an XMLElement and returns a Bool
    /// - Returns: An array of matching child elements
    public func children(where predicate: (XMLElement) -> Bool) -> [XMLElement] {
        var result: [XMLElement] = []
        for child in children {
            if let element = child as? XMLElement, predicate(element) {
                result.append(element)
            }
        }
        return result
    }
    
    /// Returns all descendant elements (direct and indirect children) matching the given predicate
    /// - Parameter predicate: A closure that takes an XMLElement and returns a Bool
    /// - Returns: An array of matching descendant elements
    public func descendants(where predicate: (XMLElement) -> Bool) -> [XMLElement] {
        var result: [XMLElement] = []
        
        for child in children {
            if let element = child as? XMLElement {
                if predicate(element) {
                    result.append(element)
                }
                result.append(contentsOf: element.descendants(where: predicate))
            }
        }
        
        return result
    }
    
    /// Returns all descendant elements including self matching the given predicate
    /// - Parameter predicate: A closure that takes an XMLElement and returns a Bool
    /// - Returns: An array of matching elements
    public func nodes(where predicate: (XMLElement) -> Bool) -> [XMLElement] {
        var result: [XMLElement] = []
        
        if predicate(self) {
            result.append(self)
        }
        
        result.append(contentsOf: descendants(where: predicate))
        
        return result
    }
    
    // MARK: - Querying
    
    /// Queries for elements using a simplified XPath-like syntax.
    ///
    /// This method allows you to find elements within the XML tree using a concise query language
    /// similar to XPath. The query engine supports navigating by element name, filtering by
    /// attributes, and using various special selectors.
    ///
    /// - Parameter queryString: The query string specifying which elements to find.
    /// - Returns: An array of all matching ``XMLElement`` instances.
    ///
    /// ## Supported Query Syntax
    ///
    /// - **Element name**: `book` (find all child elements named "book")
    /// - **Path navigation**: `book/title` (find all "title" elements that are children of "book" elements)
    /// - **Attribute filter**: `book[@category='fiction']` (find books with category attribute equal to "fiction")
    /// - **Wildcard**: `*/title` (find all "title" elements regardless of parent name)
    /// - **Index**: `book[1]` (find the first "book" element, using 1-based indexing)
    /// - **Parent**: `title/..` (find the parent of the "title" element)
    ///
    /// ## Example
    ///
    /// ```swift
    /// let library = document.root
    /// 
    /// // Find all books
    /// let books = library.query("book")
    /// 
    /// // Find books in the fiction category
    /// let fictionBooks = library.query("book[@category='fiction']")
    /// 
    /// // Find all titles of books
    /// let bookTitles = library.query("book/title")
    /// 
    /// // Find the title of the first book
    /// let firstBookTitle = library.query("book[1]/title").first
    /// ```
    ///
    /// > Note: This is a simplified XPath-like implementation. For more complex queries,
    /// > you may need to chain multiple query calls or use Swift filtering.
    public func query(_ queryString: String) -> [XMLElement] {
        return XMLQuery.execute(query: queryString, on: self)
    }
    
    /// Queries for a single element using a simplified XPath-like syntax
    /// - Parameter query: The query string
    /// - Returns: The first matching element, or nil if none found
    public func queryFirst(_ queryString: String) -> XMLElement? {
        return query(queryString).first
    }
    
    // MARK: - Dynamic Member Lookup
    
    /// Provides dynamic access to attributes
    public subscript(dynamicMember name: String) -> String? {
        get { attributes[name] }
        set {
            if let newValue = newValue {
                attributes[name] = newValue
            } else {
                attributes.removeValue(forKey: name)
            }
        }
    }
    
    // MARK: - XMLNode
    
    /// Returns the XML string representation of this element
    public var xmlString: String {
        var result = "<\(name)"
        
        // Add attributes
        for (key, value) in attributes.sorted(by: { $0.key < $1.key }) {
            let escapedValue = value.replacingOccurrences(of: "\"", with: "&quot;")
            result += " \(key)=\"\(escapedValue)\""
        }
        
        // Check if we have children or content
        if children.isEmpty && content == nil {
            result += " />"
        } else {
            result += ">"
            
            // Add content if available
            if let content = content {
                result += XMLText.escapeText(content)
            }
            
            // Add children
            for child in children {
                result += child.xmlString
            }
            
            result += "</\(name)>"
        }
        
        return result
    }
    
    // MARK: - Hashable
    
    public static func == (lhs: XMLElement, rhs: XMLElement) -> Bool {
        return lhs === rhs
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}