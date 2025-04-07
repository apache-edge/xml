#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

/// The base protocol for all XML nodes in the document tree.
///
/// `XMLNode` serves as the foundation for representing any node in an XML document.
/// All specific node types like elements, text nodes, comments, and others conform to this
/// protocol, providing a uniform interface for basic operations.
///
/// ## Types of XML Nodes
///
/// The library provides several implementations of `XMLNode`:
///
/// - ``XMLElement``: Represents an XML element with a name, attributes, and child nodes
/// - ``XMLText``: Represents text content within an element
/// - ``XMLComment``: Represents XML comments like `<!-- comment -->`
/// - ``XMLCData``: Represents CDATA sections like `<![CDATA[content]]>`
/// - ``XMLProcessingInstruction``: Represents processing instructions like `<?target data?>`
///
/// ## Working with Nodes
///
/// Most operations on XML documents involve traversing the node tree, accessing node properties,
/// and manipulating the structure. The `XMLNode` protocol provides essential properties for
/// these operations.
///
/// ```swift
/// // Example of traversing node hierarchy
/// func printNodeHierarchy(_ node: XMLNode, level: Int = 0) {
///     let indent = String(repeating: "  ", count: level)
///     print("\(indent)Node at depth: \(node.depth)")
///     
///     if let element = node as? XMLElement {
///         for child in element.children {
///             printNodeHierarchy(child, level: level + 1)
///         }
///     }
/// }
/// ```
public protocol XMLNode: AnyObject {
    /// The parent node of this node. `nil` if this is the root node
    var parent: XMLElement? { get }
    
    /// Converts this node to an XML string
    var xmlString: String { get }
    
    /// The depth of this node in the XML tree (0 for root)
    var depth: Int { get }
}

extension XMLNode {
    /// The depth of this node in the XML tree (0 for root)
    public var depth: Int {
        var count = 0
        var current = self.parent
        
        while current != nil {
            count += 1
            current = current?.parent
        }
        
        return count
    }
}