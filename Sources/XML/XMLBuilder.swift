#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

/// A builder for creating XML structures programmatically
public final class XMLBuilder {
    private var document: XMLDocument
    private var currentElement: XMLElement
    
    /// Creates a new XML builder with a root element
    /// - Parameters:
    ///   - rootName: The name of the root element
    ///   - attributes: Optional attributes for the root element
    ///   - version: The XML version, defaults to "1.0"
    ///   - encoding: The XML encoding, defaults to "UTF-8"
    public init(rootName: String, attributes: [String: String] = [:], version: String = "1.0", encoding: String = "UTF-8") {
        let root = XMLElement(name: rootName, attributes: attributes)
        self.document = XMLDocument(root: root, version: version, encoding: encoding)
        self.currentElement = root
    }
    
    /// Creates a new XML builder with an existing document
    /// - Parameter document: The XML document to build upon
    public init(document: XMLDocument) {
        self.document = document
        self.currentElement = document.root
    }
    
    /// The current XML document
    public var xmlDocument: XMLDocument {
        return document
    }
    
    /// Adds a processing instruction to the document
    /// - Parameters:
    ///   - target: The processing instruction target
    ///   - data: The processing instruction data
    /// - Returns: Self for method chaining
    @discardableResult
    public func processingInstruction(target: String, data: String) -> Self {
        let pi = XMLProcessingInstruction(target: target, data: data)
        document.addProcessingInstruction(pi)
        return self
    }
    
    /// Adds a comment to the document
    /// - Parameter text: The comment text
    /// - Returns: Self for method chaining
    @discardableResult
    public func documentComment(_ text: String) -> Self {
        let comment = XMLComment(text: text)
        document.addComment(comment)
        return self
    }
    
    /// Adds a child element to the current element
    /// - Parameters:
    ///   - name: The element name
    ///   - attributes: Optional attributes for the element
    ///   - content: Optional text content for the element
    /// - Returns: Self for method chaining
    @discardableResult
    public func element(name: String, attributes: [String: String] = [:], content: String? = nil) -> Self {
        let element = XMLElement(name: name, attributes: attributes, content: content)
        currentElement.addChild(element)
        currentElement = element
        return self
    }
    
    /// Adds a text node to the current element
    /// - Parameter text: The text content
    /// - Returns: Self for method chaining
    @discardableResult
    public func text(_ text: String) -> Self {
        let textNode = XMLText(text: text)
        currentElement.addChild(textNode)
        return self
    }
    
    /// Adds a comment to the current element
    /// - Parameter text: The comment text
    /// - Returns: Self for method chaining
    @discardableResult
    public func comment(_ text: String) -> Self {
        let comment = XMLComment(text: text)
        currentElement.addChild(comment)
        return self
    }
    
    /// Adds a CDATA section to the current element
    /// - Parameter text: The CDATA content
    /// - Returns: Self for method chaining
    @discardableResult
    public func cdata(_ text: String) -> Self {
        let cdata = XMLCData(text: text)
        currentElement.addChild(cdata)
        return self
    }
    
    /// Adds a processing instruction to the current element
    /// - Parameters:
    ///   - target: The processing instruction target
    ///   - data: The processing instruction data
    /// - Returns: Self for method chaining
    @discardableResult
    public func instruction(target: String, data: String) -> Self {
        let instruction = XMLProcessingInstruction(target: target, data: data)
        currentElement.addChild(instruction)
        return self
    }
    
    /// Sets an attribute on the current element
    /// - Parameters:
    ///   - name: The attribute name
    ///   - value: The attribute value
    /// - Returns: Self for method chaining
    @discardableResult
    public func attribute(name: String, value: String) -> Self {
        currentElement.setAttribute(name, value: value)
        return self
    }
    
    /// Sets multiple attributes on the current element
    /// - Parameter attributes: The attributes to set
    /// - Returns: Self for method chaining
    @discardableResult
    public func attributes(_ attributes: [String: String]) -> Self {
        currentElement.setAttributes(attributes)
        return self
    }
    
    /// Moves up to the parent element
    /// - Returns: Self for method chaining
    @discardableResult
    public func parent() -> Self {
        if let parent = currentElement.parent {
            currentElement = parent
        }
        return self
    }
    
    /// Performs the given actions on the current element, then returns to the previous level
    /// - Parameter actions: A closure that takes the builder
    /// - Returns: Self for method chaining
    @discardableResult
    public func withElement(_ actions: (XMLBuilder) -> Void) -> Self {
        actions(self)
        return parent()
    }
    
    /// Creates a child element, performs the given actions, then returns to the previous level
    /// - Parameters:
    ///   - name: The element name
    ///   - attributes: Optional attributes for the element
    ///   - content: Optional text content for the element
    ///   - actions: A closure that takes the builder
    /// - Returns: Self for method chaining
    @discardableResult
    public func element(name: String, attributes: [String: String] = [:], content: String? = nil, _ actions: (XMLBuilder) -> Void) -> Self {
        element(name: name, attributes: attributes, content: content)
        actions(self)
        return parent()
    }
}