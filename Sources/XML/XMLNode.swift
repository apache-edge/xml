import Foundation

/// The base protocol for all XML nodes
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